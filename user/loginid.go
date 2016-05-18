package gaeuser

import (
	"time"

	"crypto/sha1"
	"encoding/base64"
	"fmt"
	"io"
	"math/rand"
	"sort"

	"github.com/mssola/user_agent"
	"golang.org/x/net/context"
	"google.golang.org/appengine/datastore"
)

type GaeUserLoginIdItem struct {
	LoginId   string
	DeviceID  string
	IP        string    `datastore:",noindex"`
	UserName  string    `datastore:",noindex"`
	Type      string    `datastore:",noindex"`
	UserAgent string    `datastore:",noindex"`
	LoginTime time.Time `datastore:",noindex"`
}

type LoginId struct {
	GaeObject    *GaeUserLoginIdItem
	GaeObjectKey *datastore.Key
	ItemKind     string
}

//
//
//
//

func (obj *UserManager) NewLoginIdWithID(ctx context.Context, userName string, ip string, userAgent string, loginType string) *LoginId {
	//
	userObj := obj.NewUser(ctx, userName)
	//userObj.PullFromDB(ctx)
	ret := new(LoginId)
	ret.GaeObject = new(GaeUserLoginIdItem)
	deviceId, loginId, loginTime := MakeLoginId(userName, ip, userAgent)
	ret.GaeObject.LoginId = loginId
	ret.GaeObject.IP = ip
	ret.GaeObject.Type = loginType
	ret.GaeObject.LoginTime = loginTime
	ret.GaeObject.DeviceID = deviceId
	ret.GaeObject.UserName = userName
	ret.GaeObject.UserAgent = userAgent

	ret.ItemKind = obj.loginIdKind
	ret.GaeObjectKey = ret.MakeGaeObjectKey(ctx, userObj.GaeObjectKey)
	return ret
}

func (obj *UserManager) NewLoginId(ctx context.Context, userName string, ip string, userAgent string, loginType string) *LoginId {
	userObj := obj.NewLoginIdWithID(ctx, userName, ip, userAgent, loginType)
	userObj.GaeObject.LoginId = ""
	return userObj
}

//
//
//
func (obj *UserManager) NewLoginIdFromGaeObject(key *datastore.Key, item *GaeUserLoginIdItem) *LoginId {
	ret := new(LoginId)
	ret.GaeObject = item
	ret.GaeObjectKey = key
	ret.ItemKind = obj.loginIdKind
	return ret
}

func (obj *LoginId) MakeGaeObjectKey(ctx context.Context, parentKey *datastore.Key) *datastore.Key {
	return datastore.NewKey(ctx, obj.ItemKind, obj.MakeGaeObjectKeyStringId(), 0, parentKey)
}

func (obj *LoginId) MakeGaeObjectKeyStringId() string {
	return obj.ItemKind + ":" + obj.GaeObject.UserName + ":" + obj.GaeObject.DeviceID
}

func (obj *LoginId) LoadFromDB(ctx context.Context) error {
	return datastore.Get(ctx, obj.GaeObjectKey, obj.GaeObject)
}

func (obj *LoginId) IsExistedOnDB(ctx context.Context) bool {
	err := datastore.Get(ctx, obj.GaeObjectKey, obj.GaeObject)
	if err == nil {
		return true
	} else {
		return false
	}
}

func (obj *LoginId) Login(ctx context.Context) error {
	_, e := datastore.Put(ctx, obj.GaeObjectKey, obj.GaeObject)
	return e
}

func (obj *LoginId) Logout(ctx context.Context) error {
	obj.GaeObject.LoginId = ""
	_, e := datastore.Put(ctx, obj.GaeObjectKey, obj.GaeObject)
	return e
}

func (obj *LoginId) DeleteFromDB(ctx context.Context) error {
	return datastore.Delete(ctx, obj.GaeObjectKey)
}

func ExtractUserFromLoginId(loginId string) (string, error) {
	binary := []byte(loginId)
	if len(binary) <= 28 {
		return "", ErrorExtract
	}

	binaryUser, err := base64.StdEncoding.DecodeString(string(binary[28:]))
	if err != nil {
		return "", ErrorExtract
	}
	return string(binaryUser), nil
}
func MakeLoginId(userName string, ip string, userAgent string) (string, string, time.Time) {
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
		loginId += base64.StdEncoding.EncodeToString([]byte(userName))
	}
	return DeviceID, loginId, t
}

//
//
//
type LoginIdManager struct {
	IdList []*LoginId
}

func (obj *UserManager) NewLoginIdManager(ctx context.Context, userName string) *LoginIdManager {
	ret := new(LoginIdManager)
	user := obj.NewUser(ctx, userName)
	q := datastore.NewQuery(obj.loginIdKind).Ancestor(user.GaeObjectKey).Limit(20)
	i := q.Run(ctx)

	for {
		var l GaeUserLoginIdItem
		k, e := i.Next(&l)
		if e != nil {
			break
		}
		ret.IdList = append(ret.IdList, obj.NewLoginIdFromGaeObject(k, &l))
	}
	return ret
}

//--------------
// sort.Interface
//--------------
func (obj LoginIdManager) Len() int {
	return len(obj.IdList)
}

func (obj LoginIdManager) Less(i, j int) bool {
	return obj.IdList[i].GaeObject.LoginTime.UnixNano() < obj.IdList[j].GaeObject.LoginTime.UnixNano()
}

func (obj LoginIdManager) Swap(i, j int) {
	obj.IdList[i], obj.IdList[j] = obj.IdList[j], obj.IdList[i]
}

//--------------

func (obj *LoginIdManager) Logout(ctx context.Context, loginId string) error {

	l := len(obj.IdList)
	for i := 0; i < l; i++ {
		if obj.IdList[i].GaeObject.LoginId == loginId {
			obj.IdList[i].Logout(ctx)
		}
	}
	return nil
}
func (obj *LoginIdManager) DeleteOldLoginIds(ctx context.Context) error {

	l := len(obj.IdList)
	if l < 10 {
		return nil
	}
	// sort
	sort.Sort(*obj)
	//
	// delete old
	for i := 0; i < l-10; i++ {
		obj.IdList[i].DeleteFromDB(ctx)
	}
	return nil
}

func (obj *LoginIdManager) DeleteAllLoginIds(ctx context.Context) error {
	l := len(obj.IdList)
	//
	// delete old
	for i := 0; i < l; i++ {
		obj.IdList[i].DeleteFromDB(ctx)
	}
	return nil
}
