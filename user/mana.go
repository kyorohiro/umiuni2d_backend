package gaeuser

import (
	"errors"

	"google.golang.org/appengine/datastore"

	"golang.org/x/net/context"
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
	pass2 := userObj.GaeObject.PassHash
	if pass1 != pass2 {
		return "", userObj, ErrorInvalidPass
	}
	loginIdObj := obj.NewLoginIdWithID(ctx, userName, remoteAddr, userAgent, "")
	err = loginIdObj.Login(ctx)
	if err == nil {
		llist := obj.NewLoginIdManager(ctx, userName)
		llist.DeleteOldLoginIds(ctx)
	}
	return loginIdObj.GaeObject.LoginId, userObj, err
}

func (obj *UserManager) CheckLoginId(ctx context.Context, loginId string, remoteAddr string, userAgent string) (bool, string, error) {
	userName, e1 := ExtractUserFromLoginId(loginId)
	if e1 != nil {
		return false, "", e1
	}
	loginIdObj := obj.NewLoginId(ctx, userName, remoteAddr, userAgent, "")
	err := loginIdObj.LoadFromDB(ctx)
	if err != nil {
		llist := obj.NewLoginIdManager(ctx, userName)
		llist.Logout(ctx, loginId)
		return false, userName, err
	}
	if loginIdObj.GaeObject.LoginId == loginId {
		return true, userName, nil
	} else {
		return false, userName, nil
	}
}

func (obj *UserManager) LogoutUser(ctx context.Context, loginId string, remoteAddr string, userAgent string) error {
	userName, e1 := ExtractUserFromLoginId(loginId)
	if e1 != nil {
		return e1
	}
	llist := obj.NewLoginIdManager(ctx, userName)
	return llist.Logout(ctx, loginId)
}

func (obj *UserManager) DeleteUser(ctx context.Context, userName string, passIdFromClient string) error {
	user := obj.NewUser(ctx, userName)
	//
	llist := obj.NewLoginIdManager(ctx, userName)
	err := llist.DeleteAllLoginIds(ctx)
	if err != nil {
		return err
	}

	return user.Delete(ctx)
}
