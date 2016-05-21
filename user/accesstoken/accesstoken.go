package accesstoken

import (
	"errors"
	"time"

	"golang.org/x/net/context"
	"google.golang.org/appengine/datastore"
	"google.golang.org/appengine/memcache"
)

var ErrorNotFound = errors.New("not found")
var ErrorAlreadyRegist = errors.New("already found")
var ErrorAlreadyUseMail = errors.New("already use mail")
var ErrorInvalid = errors.New("invalid")
var ErrorInvalidPass = errors.New("invalid password")
var ErrorOnServer = errors.New("server error")
var ErrorExtract = errors.New("failed to extract")

type GaeAccessTokenItem struct {
	LoginId   string    `datastore:",noindex"`
	DeviceID  string    `datastore:",noindex"`
	IP        string    `datastore:",noindex"`
	UserName  string    `datastore:",noindex"`
	Type      string    `datastore:",noindex"`
	UserAgent string    `datastore:",noindex"`
	LoginTime time.Time `datastore:",noindex"`
}

type SessionManager struct {
	MemcacheExpiration time.Duration
	UseMemcache        bool
	loginIdKind        string
}

func NewAccessTokenManager(kind string, memcacheExpiration time.Duration) *SessionManager {
	ret := new(SessionManager)
	ret.loginIdKind = kind
	ret.MemcacheExpiration = memcacheExpiration
	return ret
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

func (obj *AccessToken) GetDeviceId() string {
	return obj.gaeObject.DeviceID
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

//
//
//

//
//
//
//

func (obj *SessionManager) UpdateMemcache(ctx context.Context, tokenObj *AccessToken) {
	if obj.UseMemcache == false {
		return
	}
	// err :=
	memcache.JSON.Set(ctx, &memcache.Item{
		Key:        tokenObj.gaeObject.LoginId,
		Object:     tokenObj.gaeObject,
		Expiration: obj.MemcacheExpiration,
	})
}

func (obj *SessionManager) GetMemcache(ctx context.Context, loginId string) (*AccessToken, error) {
	if obj.UseMemcache == false {
		return nil, errors.New("unuse memcache mode")
	}
	var gaeObject GaeAccessTokenItem
	_, err := memcache.JSON.Get(ctx, loginId, &gaeObject)
	//
	if err != nil {
		return nil, err
	}
	//
	deviceId, userName, err := obj.ExtractUserFromLoginId(loginId)
	loginIdObjKey := obj.NewAccessTokenGaeObjectKey(ctx, userName, deviceId, nil) // MakeLoginIdGaeObjectKeyStringId(userName, deviceId)
	//
	return obj.NewAccessTokenFromGaeObject(loginIdObjKey, &gaeObject), nil
}

func (obj *SessionManager) DeleteLoginIdFromCache(ctx context.Context, loginId string) error {
	if obj.UseMemcache == false {
		return nil
	}
	return memcache.Delete(ctx, loginId)
}
