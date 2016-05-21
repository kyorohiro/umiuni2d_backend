package gaeuser

import (
	"time"

	"crypto/sha1"
	"encoding/base64"
	"errors"
	"fmt"
	"io"
	"math/rand"
	//	"sort"

	"google.golang.org/appengine/log"

	"github.com/mssola/user_agent"
	"golang.org/x/net/context"
	"google.golang.org/appengine/datastore"
	"google.golang.org/appengine/memcache"
)

func (obj *UserManager) NewAccessToken(ctx context.Context, userName string, ip string, userAgent string, loginType string) (*AccessToken, error) {
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
	ret.gaeObjectKey = obj.NewLoginIdGaeObjectKey(ctx, userName, deviceId, userKey)

	_, e := datastore.Put(ctx, ret.gaeObjectKey, ret.gaeObject)
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
	ret.gaeObject = new(GaeAccessTokenItem)
	ret.gaeObjectKey = obj.NewLoginIdGaeObjectKey(ctx, userName, deviceId, userKey)

	err = ret.LoadFromDB(ctx)
	if err != nil {
		log.Infof(ctx, "###[ B ]### %s %s %s %s", err.Error(), deviceId, obj.loginIdKind, userKey.StringID())
		log.Infof(ctx, "###[ B1 ]### %s", ret.gaeObjectKey.Kind())
		return nil, err
	}
	log.Infof(ctx, "###[ C ]### %s %s %s")
	return ret, nil
}

//
func (obj *UserManager) NewLoginIdFromGaeObject(key *datastore.Key, item *GaeAccessTokenItem) *AccessToken {
	ret := new(AccessToken)
	ret.gaeObject = item
	ret.gaeObjectKey = key
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

func (obj *UserManager) CheckLoginIdFromCache(ctx context.Context, loginId string, ip string, userAgent string) (bool, *AccessToken, error) {
	if obj.UseMemcache == false {
		return false, nil, errors.New("unuse memcache mode")
	}
	deviceId, userName, err1 := obj.ExtractUserFromLoginId(loginId)
	if err1 != nil {
		return false, nil, err1
	}
	loginIdObj, err2 := obj.GetMemcache(ctx, loginId)

	if err2 != nil {
		return false, nil, err2
	}
	deviceIdMem := loginIdObj.gaeObject.DeviceID
	userNameMem := loginIdObj.gaeObject.UserName
	deviceIdCur, _, _ := obj.MakeLoginId(userName, ip, userAgent)

	if deviceIdMem != deviceId || userNameMem != userName {
		return false, nil, errors.New("wrong DeviceID (1)")
	}
	if deviceIdCur != deviceId {
		return false, nil, errors.New("wrong DeviceID (2)")
	}
	return true, loginIdObj, nil
}

func (obj *UserManager) UpdateMemcache(ctx context.Context, tokenObj *AccessToken) {
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

func (obj *UserManager) GetMemcache(ctx context.Context, loginId string) (*AccessToken, error) {
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
	loginIdObjKey := obj.NewLoginIdGaeObjectKey(ctx, userName, deviceId, obj.NewUserGaeObjectKey(ctx, userName)) // MakeLoginIdGaeObjectKeyStringId(userName, deviceId)
	//
	return obj.NewLoginIdFromGaeObject(loginIdObjKey, &gaeObject), nil
}

func (obj *UserManager) DeleteLoginIdFromCache(ctx context.Context, loginId string) error {
	if obj.UseMemcache == false {
		return nil
	}
	return memcache.Delete(ctx, loginId)
}
