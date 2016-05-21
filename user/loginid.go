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

	"encoding/json"

	"google.golang.org/appengine/log"

	"github.com/mssola/user_agent"
	"golang.org/x/net/context"
	"google.golang.org/appengine/datastore"
	"google.golang.org/appengine/memcache"
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

//
//
//
//
//
//
//

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

func (obj *UserManager) CheckLoginIdFromCache(ctx context.Context, loginId string, ip string, userAgent string) (bool, error) {
	deviceId, userName, err1 := obj.ExtractUserFromLoginId(loginId)
	deviceIdMem, userNameMem, err2 := obj.GetLoginIdFromCache(ctx, loginId)
	deviceIdCur, _, _ := obj.MakeLoginId(userName, ip, userAgent)
	if err1 != nil {
		log.Infof(ctx, "--------------------------(1)")
		return false, err1
	}
	if err2 != nil {
		log.Infof(ctx, "--------------------------(2)")
		return false, err2
	}

	if deviceIdMem != deviceId || userNameMem != userName {
		log.Infof(ctx, "--------------------------(3)")
		return false, errors.New("wrong DeviceID (1)")
	}
	if deviceIdCur != deviceId {
		log.Infof(ctx, "--------------------------(4)")
		//log.Infof(ctx, "---"+deviceIdCur+"--"+deviceId+":"+loginIdCur+"---"+loginId)
		log.Infof(ctx, "--------------------------(4)")
		return false, errors.New("wrong DeviceID (2)")
	}
	log.Infof(ctx, "--------------------------(5)")
	return true, nil
}

func (obj *UserManager) SetLoginIdFromCache(ctx context.Context, loginId string, deviceId string, userName string) {
	if obj.MemcacheExpiration < 0 {
		return
	}
	v := map[string]string{"loginId": loginId, "deviceId": deviceId, "userName": userName}
	b, _ := json.Marshal(v)
	c := string(b)
	err := memcache.JSON.Set(ctx, &memcache.Item{
		Key:        loginId,
		Object:     &c,
		Expiration: obj.MemcacheExpiration,
	})
	if err != nil {
		log.Infof(ctx, "--------------------------(ZZ1Z)"+err.Error())
	} else {
		log.Infof(ctx, "--------------------------(ZZ2Z)"+loginId)
	}
}

func (obj *UserManager) GetLoginIdFromCache(ctx context.Context, loginId string) (string, string, error) {
	if obj.MemcacheExpiration < 0 {
		log.Infof(ctx, "--------------------------(A)")

		return "", "", errors.New("unuse memcache setting")
	}
	var v string = ""
	_, err := memcache.JSON.Get(ctx, loginId, &v)
	if err == nil {
		log.Infof(ctx, "--------------------------(B)")

		var w map[string]string
		json.Unmarshal([]byte(v), &w)
		return w["deviceId"], w["userName"], nil
	} else {
		log.Infof(ctx, "------------------------"+loginId+"--(C)"+err.Error())

		return "", "", err
	}
}

func (obj *UserManager) DeleteLoginIdFromCache(ctx context.Context, loginId string) error {
	return memcache.Delete(ctx, loginId)
}
