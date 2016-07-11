package user

import (
	"errors"

	"google.golang.org/appengine/datastore"

	acm "umiuni2d_backend/session"

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
	userKind       string
	loginIdKind    string
	sessionManager *acm.SessionManager
	limitOfFinding int
}

func NewUserManager(userKind string, loginIdKind string) *UserManager {
	obj := new(UserManager)
	obj.sessionManager = acm.NewSessionManager(loginIdKind, 60*60*(1000*1000*1000))
	obj.userKind = userKind
	obj.loginIdKind = loginIdKind
	obj.limitOfFinding = 10
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

func (obj *UserManager) LoginUser(ctx context.Context, userName string, passIdFromClient string, remoteAddr string, userAgent string) (*acm.AccessToken, *User, error) {
	userObj, err := obj.FindUserFromUserName(ctx, userName)
	if err != nil {
		return nil, nil, ErrorNotFound
	}
	pass1 := userObj.MakeSha1Pass(passIdFromClient)
	pass2 := userObj.gaeObject.PassHash
	if pass1 != pass2 {
		return nil, userObj, ErrorInvalidPass
	}
	loginIdObj, err1 := obj.sessionManager.Login(ctx, userName, remoteAddr, userAgent, "")
	if err != nil {
		return nil, userObj, err1
	} else {
		return loginIdObj, userObj, err1
	}
}

func (obj *UserManager) CheckLoginId(ctx context.Context, loginId string, remoteAddr string, userAgent string) (bool, *acm.AccessToken, error) {
	isCheck, tokenObj, err := obj.sessionManager.CheckLoginId(ctx, loginId, remoteAddr, userAgent)
	if isCheck == false && tokenObj != nil {
		if tokenObj.GetLoginId() != "" {
			tokenObj.Logout(ctx)
		}
	}
	return isCheck, tokenObj, err
}

func (obj *UserManager) LogoutUser(ctx context.Context, loginId string, remoteAddr string, userAgent string) error {
	return obj.sessionManager.Logout(ctx, loginId, remoteAddr, userAgent)
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

//
//
//
func (obj *UserManager) newCursorFromSrc(cursorSrc string) *datastore.Cursor {
	c1, e := datastore.DecodeCursor(cursorSrc)
	if e != nil {
		return nil
	} else {
		return &c1
	}
}

func (obj *UserManager) makeCursorSrc(founds *datastore.Iterator) string {
	c, e := founds.Cursor()
	if e == nil {
		return c.String()
	} else {
		return ""
	}
}

//
//
func (obj *UserManager) FindUserWithNewOrder(ctx context.Context, cursorSrc string) ([]*User, string, string) {
	q := datastore.NewQuery(obj.userKind).Limit(obj.limitOfFinding)
	//	q := datastore.NewQuery(obj.userKind).Order("-Updated").Limit(obj.limitOfFinding)
	return obj.FindUserFromQuery(ctx, q, cursorSrc)
}

//
//
func (obj *UserManager) FindUserFromQuery(ctx context.Context, q *datastore.Query, cursorSrc string) ([]*User, string, string) {
	cursor := obj.newCursorFromSrc(cursorSrc)
	if cursor != nil {
		q = q.Start(*cursor)
	}
	founds := q.Run(ctx)

	var retUser []*User

	var cursorNext string = ""
	var cursorOne string = ""

	for i := 0; ; i++ {
		var d GaeUserItem
		key, err := founds.Next(&d)
		if err != nil || err == datastore.Done {
			break
		} else {
			retUser = append(retUser, obj.NewUserFromsGaeObject(key, &d))
		}
		if i == 0 {
			cursorOne = obj.makeCursorSrc(founds)
		}
	}
	cursorNext = obj.makeCursorSrc(founds)
	return retUser, cursorOne, cursorNext
}
