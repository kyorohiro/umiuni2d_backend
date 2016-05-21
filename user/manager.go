package gaeuser

import (
	"errors"

	"google.golang.org/appengine/datastore"

	"time"

	acm "umiuni2d_backend/user/accesstoken"

	"golang.org/x/net/context"
	//	"google.golang.org/appengine/log"
)

const (
	UserStatusDelete = "delete"
)

var ErrorNotFound = errors.New("not found")
var ErrorAlreadyRegist = errors.New("already found")
var ErrorAlreadyUseMail = errors.New("already use mail")
var ErrorInvalid = errors.New("invalid")
var ErrorInvalidPass = errors.New("invalid password")
var ErrorOnServer = errors.New("server error")
var ErrorExtract = errors.New("failed to extract")

type UserManager struct {
	userKind           string
	loginIdKind        string
	MemcacheExpiration time.Duration
	accessTokenManager *acm.AccessTokenManager
	UseMemcache        bool
}

func NewUserManager(userKind string, loginIdKind string) *UserManager {
	obj := new(UserManager)
	obj.accessTokenManager = acm.NewAccessTokenManager(loginIdKind, obj.NewUserGaeObjectKey)
	obj.userKind = userKind
	obj.loginIdKind = loginIdKind
	obj.MemcacheExpiration = 60 * 60 * (1000 * 1000 * 1000)
	obj.UseMemcache = true
	return obj
}

func (obj *UserManager) GetUserKind() string {
	return obj.userKind
}

func (obj *UserManager) GetLoginIdKind() string {
	return obj.loginIdKind
}

func (obj *UserManager) FindUserFromUserName(ctx context.Context, userName string) (*User, error) {
	user := obj.NewUser(ctx, userName)
	e := user.LoadFromDB(ctx)
	return user, e
}

func (obj *UserManager) FindUserFromMail(ctx context.Context, mail string) (*User, error) {
	q := datastore.NewQuery(obj.userKind).Filter("Mail =", mail).Limit(1)
	i := q.Run(ctx)
	var userIns GaeUserItem
	k, e := i.Next(&userIns)
	if e != nil {
		return nil, e
	}
	return obj.NewUserFromsGaeObject(k, &userIns), e
}

func (obj *UserManager) RegistUser(ctx context.Context, userName string, passIdFromClient string, email string) (*User, error) {
	user := obj.NewUser(ctx, userName)
	return user, user.Regist(ctx, passIdFromClient, email)
}

func (obj *UserManager) LoginUser(ctx context.Context, userName string, passIdFromClient string, remoteAddr string, userAgent string) (string, *User, error) {
	userObj, err := obj.FindUserFromUserName(ctx, userName)
	if err != nil {
		return "", nil, ErrorNotFound
	}
	pass1 := userObj.MakeSha1Pass(passIdFromClient)
	pass2 := userObj.gaeObject.PassHash
	if pass1 != pass2 {
		return "", userObj, ErrorInvalidPass
	}
	loginIdObj, err1 := obj.accessTokenManager.NewAccessToken(ctx, userName, remoteAddr, userAgent, "")
	if err1 == nil {
		obj.accessTokenManager.UpdateMemcache(ctx, loginIdObj)
	}
	return loginIdObj.GetLoginId(), userObj, err1
}

func (obj *UserManager) CheckLoginId(ctx context.Context, loginId string, remoteAddr string, userAgent string) (bool, *acm.AccessToken, error) {
	//
	//	cisLogin, cloginIdObj, cerr := obj.CheckLoginIdFromCache(ctx, loginId, remoteAddr, userAgent)
	var loginIdObj *acm.AccessToken
	var err error

	loginIdObj, err = obj.accessTokenManager.GetMemcache(ctx, loginId)
	if err != nil {
		loginIdObj, err = obj.accessTokenManager.LoadAccessTokenFromLoginId(ctx, loginId)
	}
	if err != nil {
		return false, nil, err
	}

	reqDeviceId, _, _ := obj.accessTokenManager.MakeLoginId(loginIdObj.GetUserName(), remoteAddr, userAgent)
	if loginIdObj.GetDeviceId() != reqDeviceId || loginIdObj.GetLoginId() != loginId {
		if loginIdObj.GetLoginId() != "" {
			loginIdObj.Logout(ctx)
		}
		return false, nil, err
	}
	obj.accessTokenManager.UpdateMemcache(ctx, loginIdObj)
	return true, loginIdObj, nil
}

func (obj *UserManager) LogoutUser(ctx context.Context, loginId string, remoteAddr string, userAgent string) error {
	isLogin, loginIdObj, err := obj.CheckLoginId(ctx, loginId, remoteAddr, userAgent)
	if err != nil {
		return err
	}
	if isLogin == false {
		return nil
	}
	obj.accessTokenManager.DeleteLoginIdFromCache(ctx, loginId)
	return loginIdObj.Logout(ctx)
}

func (obj *UserManager) DeleteUser(ctx context.Context, userName string, passIdFromClient string) error {
	user := obj.NewUser(ctx, userName)
	err := user.LoadFromDB(ctx)
	if err != nil {
		return err
	}
	user.gaeObject.Status = UserStatusDelete
	err = user.PushToDB(ctx)
	return err
}
