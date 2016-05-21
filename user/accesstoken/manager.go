package accesstoken

import (
	"time"

	"crypto/sha1"
	"encoding/base64"
	"errors"
	"fmt"
	"io"
	"math/rand"
	//	"sort"

	//	"google.golang.org/appengine/log"

	"github.com/mssola/user_agent"
	"golang.org/x/net/context"
	"google.golang.org/appengine/datastore"
	"google.golang.org/appengine/memcache"
)

func (obj *AccessTokenManager) NewAccessToken(ctx context.Context, userName string, ip string, userAgent string, loginType string) (*AccessToken, error) {
	//
	userKey := obj.NewUserGaeObjectKey(ctx, userName)
	ret := new(AccessToken)
	ret.gaeObject = new(GaeAccessTokenItem)
	deviceId, loginId, loginTime := obj.MakeLoginId(userName, ip, userAgent)
	ret.gaeObject.LoginId = loginId
	ret.gaeObject.IP = ip
	ret.gaeObject.Type = loginType
	ret.gaeObject.LoginTime = loginTime
	ret.gaeObject.DeviceID = deviceId
	ret.gaeObject.UserName = userName
	ret.gaeObject.UserAgent = userAgent

	ret.ItemKind = obj.loginIdKind
	ret.gaeObjectKey = obj.NewAccessTokenGaeObjectKey(ctx, userName, deviceId, userKey)

	_, e := datastore.Put(ctx, ret.gaeObjectKey, ret.gaeObject)
	return ret, e
}

func (obj *AccessTokenManager) LoadAccessTokenFromLoginId(ctx context.Context, loginId string) (*AccessToken, error) {
	deviceId, userName, err := obj.ExtractUserFromLoginId(loginId)
	if err != nil {
		return nil, err
	}
	userKey := obj.NewUserGaeObjectKey(ctx, userName)
	ret := new(AccessToken)
	ret.ItemKind = obj.loginIdKind
	ret.gaeObject = new(GaeAccessTokenItem)
	ret.gaeObjectKey = obj.NewAccessTokenGaeObjectKey(ctx, userName, deviceId, userKey)

	err = ret.LoadFromDB(ctx)
	if err != nil {
		return nil, err
	}
	return ret, nil
}

//
func (obj *AccessTokenManager) NewAccessTokenFromGaeObject(key *datastore.Key, item *GaeAccessTokenItem) *AccessToken {
	ret := new(AccessToken)
	ret.gaeObject = item
	ret.gaeObjectKey = key
	ret.ItemKind = obj.loginIdKind
	return ret
}

func (obj *AccessTokenManager) NewAccessTokenGaeObjectKey(ctx context.Context, userName string, deviceId string, parentKey *datastore.Key) *datastore.Key {
	return datastore.NewKey(ctx, obj.loginIdKind, obj.MakeLoginIdGaeObjectKeyStringId(userName, deviceId), 0, parentKey)
}

func (obj *AccessTokenManager) MakeLoginIdGaeObjectKeyStringId(userName string, deviceId string) string {
	return obj.loginIdKind + ":" + userName + ":" + deviceId
}

func (obj *AccessTokenManager) ExtractUserFromLoginId(loginId string) (string, string, error) {
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

func (obj *AccessTokenManager) MakeLoginId(userName string, ip string, userAgent string) (string, string, time.Time) {
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

//
//
//
//

func (obj *AccessTokenManager) UpdateMemcache(ctx context.Context, tokenObj *AccessToken) {
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

func (obj *AccessTokenManager) GetMemcache(ctx context.Context, loginId string) (*AccessToken, error) {
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
	loginIdObjKey := obj.NewAccessTokenGaeObjectKey(ctx, userName, deviceId, obj.NewUserGaeObjectKey(ctx, userName)) // MakeLoginIdGaeObjectKeyStringId(userName, deviceId)
	//
	return obj.NewAccessTokenFromGaeObject(loginIdObjKey, &gaeObject), nil
}

func (obj *AccessTokenManager) DeleteLoginIdFromCache(ctx context.Context, loginId string) error {
	if obj.UseMemcache == false {
		return nil
	}
	return memcache.Delete(ctx, loginId)
}
