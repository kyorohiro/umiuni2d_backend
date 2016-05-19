// gaeuser project gaeuser.go
package gaeuser

import (
	"crypto/sha1"
	"encoding/base64"
	"io"
	"time"

	"golang.org/x/net/context"
	"google.golang.org/appengine/datastore"
)

type GaeUserItem struct {
	UserName string    `datastore:",noindex"`
	Created  time.Time `datastore:",noindex"`
	Logined  time.Time `datastore:",noindex"`
	Mail     string
	PassHash string `datastore:",noindex"`
	MeIcon   string `datastore:",noindex"`
	Status   string
}

type User struct {
	gaeObject    *GaeUserItem
	gaeObjectKey *datastore.Key
	kind         string
}

func (obj *User) GetUserName() string {
	return obj.gaeObject.UserName
}

func (obj *User) GetCreated() time.Time {
	return obj.gaeObject.Created
}

func (obj *User) GetLogined() time.Time {
	return obj.gaeObject.Logined
}

func (obj *User) GetMail() string {
	return obj.gaeObject.Mail
}

func (obj *User) SetMail(v string) {
	obj.gaeObject.Mail = v
}

func (obj *User) GetMeIcon() string {
	return obj.gaeObject.MeIcon
}

func (obj *User) SetMeIcon(v string) {
	obj.gaeObject.MeIcon = v
}

func (obj *User) GetStatus() string {
	return obj.gaeObject.Status
}

func (obj *User) GetPassHash() string {
	return obj.gaeObject.PassHash
}

func (obj *User) UpdatePassword(v string) {
	obj.gaeObject.PassHash = obj.MakeSha1Pass(v)
}

func (obj *User) CheckPassword(v string) bool {
	if obj.gaeObject.PassHash == obj.MakeSha1Pass(v) {
		return true
	} else {
		return false
	}
}

//
//
func (obj *UserManager) NewUser(ctx context.Context, userName string) *User {
	ret := new(User)
	ret.kind = obj.userKind
	ret.gaeObject = new(GaeUserItem)
	ret.gaeObject.UserName = userName
	ret.gaeObjectKey = obj.NewUserGaeObjectKey(ctx, userName)
	return ret
}

//
// need load or make
func (obj *UserManager) NewUserFromsGaeObject(key *datastore.Key, item *GaeUserItem) *User {
	ret := new(User)
	ret.gaeObject = item
	ret.gaeObjectKey = key
	ret.kind = obj.userKind
	return ret
}

func (obj *UserManager) MakeUserGaeObjectKeyStringId(userName string) string {
	return obj.userKind + ":" + userName
}

func (obj *UserManager) NewUserGaeObjectKey(ctx context.Context, userName string) *datastore.Key {
	return datastore.NewKey(ctx, obj.userKind, obj.MakeUserGaeObjectKeyStringId(userName), 0, nil)
}

func (obj *User) MakeSha1Pass(passIdFromClient string) string {
	sha1Hash := sha1.New()
	io.WriteString(sha1Hash, passIdFromClient)
	io.WriteString(sha1Hash, obj.gaeObject.UserName)
	return base64.StdEncoding.EncodeToString(sha1Hash.Sum(nil))
}

func (obj *User) LoadFromDB(ctx context.Context) error {
	return datastore.Get(ctx, obj.gaeObjectKey, obj.gaeObject)
}

func (obj *User) PushToDB(ctx context.Context) error {
	_, e := datastore.Put(ctx, obj.gaeObjectKey, obj.gaeObject)
	return e
}

func (obj *User) IsExistedOnDB(ctx context.Context) bool {
	err := datastore.Get(ctx, obj.gaeObjectKey, obj.gaeObject)
	if err == nil {
		return true
	} else {
		return false
	}
}

func (obj *User) Regist(ctx context.Context, passIdFromClient string, email string) error {
	if true == obj.IsExistedOnDB(ctx) {
		return ErrorAlreadyRegist
	}
	obj.gaeObject.UserName = obj.gaeObject.UserName
	obj.gaeObject.PassHash = obj.MakeSha1Pass(passIdFromClient)
	obj.gaeObject.Mail = email

	_, e := datastore.Put(ctx, obj.gaeObjectKey, obj.gaeObject)
	return e
}

func (obj *User) Delete(ctx context.Context) error {
	err := obj.LoadFromDB(ctx)
	if err != nil {
		return ErrorNotFound
	}
	return datastore.RunInTransaction(ctx, func(ctx context.Context) error {
		e := datastore.Delete(ctx, obj.gaeObjectKey)
		if e != nil {
			return datastore.ErrConcurrentTransaction
		}
		return nil
	}, &datastore.TransactionOptions{XG: true})
}
