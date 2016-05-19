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
	GaeObject    *GaeUserItem
	GaeObjectKey *datastore.Key
	kind         string
}

func (obj *UserManager) NewUser(ctx context.Context, userName string) *User {
	ret := new(User)
	ret.kind = obj.userKind
	ret.GaeObject = new(GaeUserItem)
	ret.GaeObject.UserName = userName
	ret.GaeObjectKey = obj.NewUserGaeObjectKey(ctx, userName)
	return ret
}

/*
func (obj *UserManager) NewUserKey(ctx context.Context, userName string) *User {
	ret.GaeObjectKey = ret.MakeGaeObjectKey(ctx)
	return ret
}
*/

//
// need load or make
func (obj *UserManager) NewUserFromsGaeObject(key *datastore.Key, item *GaeUserItem) *User {
	ret := new(User)
	ret.GaeObject = item
	ret.GaeObjectKey = key
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
	io.WriteString(sha1Hash, obj.GaeObject.UserName)
	return base64.StdEncoding.EncodeToString(sha1Hash.Sum(nil))
}

func (obj *User) LoadFromDB(ctx context.Context) error {
	return datastore.Get(ctx, obj.GaeObjectKey, obj.GaeObject)
}

func (obj *User) PushToDB(ctx context.Context) error {
	_, e := datastore.Put(ctx, obj.GaeObjectKey, obj.GaeObject)
	return e
}

func (obj *User) IsExistedOnDB(ctx context.Context) bool {
	err := datastore.Get(ctx, obj.GaeObjectKey, obj.GaeObject)
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
	obj.GaeObject.UserName = obj.GaeObject.UserName
	obj.GaeObject.PassHash = obj.MakeSha1Pass(passIdFromClient)
	obj.GaeObject.Mail = email

	_, e := datastore.Put(ctx, obj.GaeObjectKey, obj.GaeObject)
	return e
}

func (obj *User) Delete(ctx context.Context) error {
	err := obj.LoadFromDB(ctx)
	if err != nil {
		return ErrorNotFound
	}
	return datastore.RunInTransaction(ctx, func(ctx context.Context) error {
		e := datastore.Delete(ctx, obj.GaeObjectKey)
		if e != nil {
			return datastore.ErrConcurrentTransaction
		}
		return nil
	}, &datastore.TransactionOptions{XG: true})
}
