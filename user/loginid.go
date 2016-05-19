package gaeuser

import (
	"time"

	"crypto/sha1"
	"encoding/base64"
	"fmt"
	"io"
	"math/rand"
	//	"sort"

	"github.com/mssola/user_agent"
	"golang.org/x/net/context"
	"google.golang.org/appengine/datastore"
)

type GaeAccessTokenItem struct {
	LoginId   string
	DeviceID  string
	IP        string    `datastore:",noindex"`
	UserName  string    `datastore:",noindex"`
	Type      string    `datastore:",noindex"`
	UserAgent string    `datastore:",noindex"`
	LoginTime time.Time `datastore:",noindex"`
}

type AccessToken struct {
	GaeObject    *GaeAccessTokenItem
	GaeObjectKey *datastore.Key
	ItemKind     string
}

//
//
//
//

func (obj *UserManager) NewAccessToken(ctx context.Context, userName string, ip string, userAgent string, loginType string) (*AccessToken, error) {
	//
	userKey := obj.NewUserGaeObjectKey(ctx, userName)
	ret := new(AccessToken)
	ret.GaeObject = new(GaeAccessTokenItem)
	deviceId, loginId, loginTime := obj.MakeLoginId(userName, ip, userAgent)
	ret.GaeObject.LoginId = loginId
	ret.GaeObject.IP = ip
	ret.GaeObject.Type = loginType
	ret.GaeObject.LoginTime = loginTime
	ret.GaeObject.DeviceID = deviceId
	ret.GaeObject.UserName = userName
	ret.GaeObject.UserAgent = userAgent

	ret.ItemKind = obj.loginIdKind
	ret.GaeObjectKey = obj.NewLoginIdGaeObjectKey(ctx, userName, deviceId, userKey)

	_, e := datastore.Put(ctx, ret.GaeObjectKey, ret.GaeObject)
	return ret, e
}

func (obj *UserManager) LoadAccessTokenFromLoginId(ctx context.Context, loginId string) (*AccessToken, error) {
	deviceId, userName, err := obj.ExtractUserFromLoginId(loginId)
	if err != nil {
		return nil, err
	}
	userKey := obj.NewUserGaeObjectKey(ctx, userName)
	ret := new(AccessToken)
	ret.ItemKind = obj.loginIdKind
	ret.GaeObject = new(GaeAccessTokenItem)
	ret.GaeObjectKey = datastore.NewKey(ctx, obj.loginIdKind, deviceId, 0, userKey)

	err = ret.LoadFromDB(ctx)
	if err != nil {
		return nil, err
	}
	return ret, nil
}

//
func (obj *UserManager) NewLoginIdFromGaeObject(key *datastore.Key, item *GaeAccessTokenItem) *AccessToken {
	ret := new(AccessToken)
	ret.GaeObject = item
	ret.GaeObjectKey = key
	ret.ItemKind = obj.loginIdKind
	return ret
}

func (obj *UserManager) NewLoginIdGaeObjectKey(ctx context.Context, userName string, deviceId string, parentKey *datastore.Key) *datastore.Key {
	return datastore.NewKey(ctx, obj.loginIdKind, obj.MakeLoginIdGaeObjectKeyStringId(userName, deviceId), 0, parentKey)
}

func (obj *UserManager) MakeLoginIdGaeObjectKeyStringId(userName string, deviceId string) string {
	return obj.loginIdKind + ":" + userName + ":" + deviceId
}

func (obj *UserManager) ExtractUserFromLoginId(loginId string) (string, string, error) {
	binary := []byte(loginId)
	if len(binary) <= 28+28+1 {
		return "", "", ErrorExtract
	}

	binaryUser, err := base64.StdEncoding.DecodeString(string(binary[28*2:]))
	if err != nil {
		return "", "", ErrorExtract
	}
	return string(binary[28 : 28*2]), string(binaryUser), nil
}

func (obj *UserManager) MakeLoginId(userName string, ip string, userAgent string) (string, string, time.Time) {
	t := time.Now()
	uaObj := user_agent.New(userAgent)
	DeviceID := ""
	loginId := ""
	{
		sha1Hash := sha1.New()
		b, _ := uaObj.Browser()
		io.WriteString(sha1Hash, b)
		io.WriteString(sha1Hash, uaObj.OS())
		io.WriteString(sha1Hash, uaObj.Platform())
		DeviceID = base64.StdEncoding.EncodeToString(sha1Hash.Sum(nil))
	}
	{
		sha1Hash := sha1.New()
		io.WriteString(sha1Hash, DeviceID)
		io.WriteString(sha1Hash, userName)
		io.WriteString(sha1Hash, fmt.Sprintf("%X%X", t.UnixNano(), rand.Int63()))
		loginId = base64.StdEncoding.EncodeToString(sha1Hash.Sum(nil))
		loginId += DeviceID
		loginId += base64.StdEncoding.EncodeToString([]byte(userName))
	}
	return DeviceID, loginId, t
}

///
///
///
func (obj *AccessToken) LoadFromDB(ctx context.Context) error {
	return datastore.Get(ctx, obj.GaeObjectKey, obj.GaeObject)
}

func (obj *AccessToken) IsExistedOnDB(ctx context.Context) bool {
	err := datastore.Get(ctx, obj.GaeObjectKey, obj.GaeObject)
	if err == nil {
		return true
	} else {
		return false
	}
}

func (obj *AccessToken) Save(ctx context.Context) error {
	_, e := datastore.Put(ctx, obj.GaeObjectKey, obj.GaeObject)
	return e
}

func (obj *AccessToken) Logout(ctx context.Context) error {
	obj.GaeObject.LoginId = ""
	_, e := datastore.Put(ctx, obj.GaeObjectKey, obj.GaeObject)
	return e
}

func (obj *AccessToken) DeleteFromDB(ctx context.Context) error {
	return datastore.Delete(ctx, obj.GaeObjectKey)
}
