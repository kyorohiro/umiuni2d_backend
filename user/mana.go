package gaeuser

import (
	"errors"

	"google.golang.org/appengine/datastore"

	"golang.org/x/net/context"
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
	userKind    string
	loginIdKind string
}

func NewUserManager(userKind string, loginIdKind string) *UserManager {
	obj := new(UserManager)
	obj.userKind = userKind
	obj.loginIdKind = loginIdKind
	return obj
}

func (obj *UserManager) GetUserKind() string {
	return obj.userKind
}

func (obj *UserManager) GetLoginIdKind() string {
	return obj.loginIdKind
}

func (obj *UserManager) GetFromUserName(ctx context.Context, userName string) (*User, error) {
	user := obj.NewUser(ctx, userName)
	e := user.LoadFromDB(ctx)
	return user, e
}

func (obj *UserManager) GetUserFromMail(ctx context.Context, mail string) (*User, error) {
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
	userObj, err := obj.GetFromUserName(ctx, userName)
	if err != nil {
		return "", nil, ErrorNotFound
	}
	pass1 := userObj.MakeSha1Pass(passIdFromClient)
	pass2 := userObj.gaeObject.PassHash
	if pass1 != pass2 {
		return "", userObj, ErrorInvalidPass
	}
	loginIdObj, err1 := obj.NewAccessToken(ctx, userName, remoteAddr, userAgent, "")

	return loginIdObj.gaeObject.LoginId, userObj, err1
}

func (obj *UserManager) CheckLoginId(ctx context.Context, loginId string, remoteAddr string, userAgent string) (bool, *AccessToken, error) {

	loginIdObj, err := obj.LoadAccessTokenFromLoginId(ctx, loginId)
	if err != nil {
		return false, nil, err
	}

	reqDeviceId, _, _ := obj.MakeLoginId(loginIdObj.gaeObject.UserName, remoteAddr, userAgent)
	if loginIdObj.gaeObject.DeviceID != reqDeviceId || loginIdObj.gaeObject.LoginId != loginId {
		if loginIdObj.gaeObject.LoginId != "" {
			loginIdObj.gaeObject.LoginId = ""
			loginIdObj.Save(ctx)
		}
		return false, nil, err
	}

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
