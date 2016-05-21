package gaeuser

import (
	"crypto/rand"
	"encoding/binary"
	"encoding/json"
	"strconv"

	"golang.org/x/net/context"
)

//
// And Regist LoginID
//
func (obj *UserManager) RegistUserFromTwitter(ctx context.Context, screenName string, userId string, oauthToken string, oauthSecret string) (*User, error) {
	user := obj.NewUser(ctx, screenName+"@twitter")
	dummyPass := screenName + obj.MakeRandomId() + obj.MakeRandomId()
	return user, user.Regist(ctx, dummyPass, "")
}

func (obj *UserManager) LoginUserFromTwitter(ctx context.Context, //
	screenName string, userId string, oauthToken string, oauthSecret string, //
	remoteAddr string, userAgent string) (string, *User, error) {
	userObj, err := obj.FindUserFromUserName(ctx, screenName+"@twitter")
	if err != nil {
		return "", nil, ErrorNotFound
	}
	//
	//
	m := map[string]interface{}{"oauth_token": oauthToken, "oauth_token_secret": oauthSecret, "screen_name ": screenName, "user_id": userId}
	b, _ := json.Marshal(m)
	//
	loginIdObj, err1 := obj.sessionManager.Login(ctx, screenName+"@twitter", remoteAddr, userAgent, string(b))
	if err != nil {
		return "", userObj, err1
	} else {
		return loginIdObj.GetLoginId(), userObj, err1
	}
}

func (obj *UserManager) MakeRandomId() string {
	var n uint64
	binary.Read(rand.Reader, binary.LittleEndian, &n)
	return strconv.FormatUint(n, 36)
}
