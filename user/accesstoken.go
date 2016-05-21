package gaeuser

import (
	"time"

	"golang.org/x/net/context"
	"google.golang.org/appengine/datastore"
)

type GaeAccessTokenItem struct {
	LoginId   string    `datastore:",noindex"`
	DeviceID  string    `datastore:",noindex"`
	IP        string    `datastore:",noindex"`
	UserName  string    `datastore:",noindex"`
	Type      string    `datastore:",noindex"`
	UserAgent string    `datastore:",noindex"`
	LoginTime time.Time `datastore:",noindex"`
}

type AccessToken struct {
	gaeObject    *GaeAccessTokenItem
	gaeObjectKey *datastore.Key
	ItemKind     string
}

func (obj *AccessToken) GetLoginId() string {
	return obj.gaeObject.LoginId
}

func (obj *AccessToken) GetUserName() string {
	return obj.gaeObject.UserName
}

func (obj *AccessToken) GetIP() string {
	return obj.gaeObject.IP
}

func (obj *AccessToken) GetUserAgent() string {
	return obj.gaeObject.UserAgent
}

func (obj *AccessToken) GetLoginTime() time.Time {
	return obj.gaeObject.LoginTime
}

func (obj *AccessToken) GetGAEObjectKey() *datastore.Key {
	return obj.gaeObjectKey
}

func (obj *AccessToken) LoadFromDB(ctx context.Context) error {
	return datastore.Get(ctx, obj.gaeObjectKey, obj.gaeObject)
}

func (obj *AccessToken) IsExistedOnDB(ctx context.Context) bool {
	err := datastore.Get(ctx, obj.gaeObjectKey, obj.gaeObject)
	if err == nil {
		return true
	} else {
		return false
	}
}

func (obj *AccessToken) Save(ctx context.Context) error {
	_, e := datastore.Put(ctx, obj.gaeObjectKey, obj.gaeObject)
	return e
}

func (obj *AccessToken) Logout(ctx context.Context) error {
	obj.gaeObject.LoginId = ""
	_, e := datastore.Put(ctx, obj.gaeObjectKey, obj.gaeObject)
	return e
}

func (obj *AccessToken) DeleteFromDB(ctx context.Context) error {
	return datastore.Delete(ctx, obj.gaeObjectKey)
}
