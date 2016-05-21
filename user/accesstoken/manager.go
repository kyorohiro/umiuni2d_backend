package accesstoken

import (
	"time"

	"crypto/sha1"
	"encoding/base64"
	//	"errors"
	"fmt"
	"io"
	"math/rand"
	//	"sort"

	//	"google.golang.org/appengine/log"

	"github.com/mssola/user_agent"
	"golang.org/x/net/context"
	"google.golang.org/appengine/datastore"
	//	"google.golang.org/appengine/memcache"
)

func (obj *SessionManager) NewAccessToken(ctx context.Context, userName string, ip string, userAgent string, loginType string) (*AccessToken, error) {
	//
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
	ret.gaeObjectKey = obj.NewAccessTokenGaeObjectKey(ctx, userName, deviceId, nil)

	_, e := datastore.Put(ctx, ret.gaeObjectKey, ret.gaeObject)
	return ret, e
}

func (obj *SessionManager) NewAccessTokenFromLoginId(ctx context.Context, loginId string) (*AccessToken, error) {
	deviceId, userName, err := obj.ExtractUserFromLoginId(loginId)
	if err != nil {
		return nil, err
	}
	ret := new(AccessToken)
	ret.ItemKind = obj.loginIdKind
	ret.gaeObject = new(GaeAccessTokenItem)
	ret.gaeObjectKey = obj.NewAccessTokenGaeObjectKey(ctx, userName, deviceId, nil)

	err = ret.LoadFromDB(ctx)
	if err != nil {
		return nil, err
	}
	return ret, nil
}

//
func (obj *SessionManager) NewAccessTokenFromGaeObject(key *datastore.Key, item *GaeAccessTokenItem) *AccessToken {
	ret := new(AccessToken)
	ret.gaeObject = item
	ret.gaeObjectKey = key
	ret.ItemKind = obj.loginIdKind
	return ret
}

func (obj *SessionManager) NewAccessTokenGaeObjectKey(ctx context.Context, userName string, deviceId string, parentKey *datastore.Key) *datastore.Key {
	return datastore.NewKey(ctx, obj.loginIdKind, obj.makeLoginIdGaeObjectKeyStringId(userName, deviceId), 0, parentKey)
}

func (obj *SessionManager) makeLoginIdGaeObjectKeyStringId(userName string, deviceId string) string {
	return obj.loginIdKind + ":" + userName + ":" + deviceId
}

//
//
//
func (obj *SessionManager) ExtractUserFromLoginId(loginId string) (string, string, error) {
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

func (obj *SessionManager) MakeDeviceId(userName string, ip string, userAgent string) string {
	uaObj := user_agent.New(userAgent)
	sha1Hash := sha1.New()
	b, _ := uaObj.Browser()
	io.WriteString(sha1Hash, b)
	io.WriteString(sha1Hash, uaObj.OS())
	io.WriteString(sha1Hash, uaObj.Platform())
	return base64.StdEncoding.EncodeToString(sha1Hash.Sum(nil))
}

func (obj *SessionManager) MakeLoginId(userName string, ip string, userAgent string) (string, string, time.Time) {
	t := time.Now()
	DeviceID := obj.MakeDeviceId(userName, ip, userAgent)
	loginId := ""
	sha1Hash := sha1.New()
	io.WriteString(sha1Hash, DeviceID)
	io.WriteString(sha1Hash, userName)
	io.WriteString(sha1Hash, fmt.Sprintf("%X%X", t.UnixNano(), rand.Int63()))
	loginId = base64.StdEncoding.EncodeToString(sha1Hash.Sum(nil))
	loginId += DeviceID
	loginId += base64.StdEncoding.EncodeToString([]byte(userName))
	return DeviceID, loginId, t
}

func (obj *SessionManager) CheckLoginId(ctx context.Context, loginId string, remoteAddr string, userAgent string) (bool, *AccessToken, error) {
	//
	var loginIdObj *AccessToken
	var err error

	loginIdObj, err = obj.GetMemcache(ctx, loginId)
	if err != nil {
		loginIdObj, err = obj.NewAccessTokenFromLoginId(ctx, loginId)
	}
	if err != nil {
		return false, nil, err
	}
	reqDeviceId, _, _ := obj.MakeLoginId(loginIdObj.GetUserName(), remoteAddr, userAgent)
	if loginIdObj.GetDeviceId() != reqDeviceId || loginIdObj.GetLoginId() != loginId {
		return false, loginIdObj, nil
	}
	obj.UpdateMemcache(ctx, loginIdObj)
	return true, loginIdObj, nil
}

func (obj *SessionManager) Login(ctx context.Context, userName string, remoteAddr string, userAgent string, loginType string) (*AccessToken, error) {
	loginIdObj, err1 := obj.NewAccessToken(ctx, userName, remoteAddr, userAgent, loginType)
	if err1 == nil {
		obj.UpdateMemcache(ctx, loginIdObj)
	}
	return loginIdObj, err1
}

func (obj *SessionManager) Logout(ctx context.Context, loginId string, remoteAddr string, userAgent string) error {
	isLogin, loginIdObj, err := obj.CheckLoginId(ctx, loginId, remoteAddr, userAgent)
	if err != nil {
		return err
	}
	if isLogin == false {
		return nil
	}
	obj.DeleteLoginIdFromCache(ctx, loginId)
	return loginIdObj.Logout(ctx)
}
