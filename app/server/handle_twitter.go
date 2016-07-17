package hello

import (
	"encoding/json"
	"net/http"
	"net/url"

	"strings"
	"umiuni2d_backend/twitter"

	"google.golang.org/appengine"
)

func twitterLoginEntry(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	ctx := appengine.NewContext(r)
	var requestPropery map[string]interface{}
	json.NewDecoder(r.Body).Decode(&requestPropery)
	reqId := getStringFromProp(requestPropery, ReqPropertyRequestID, "")
	callback := getStringFromProp(requestPropery, ReqPropertyUrl, "")

	twitterObj := GetTwitterManager()
	oauthUrl, _, err := twitterObj.SendRequestToken(ctx, twitterCallback+"?cb="+url.QueryEscape(callback))
	if err != nil {
		Response(w, map[string]interface{}{ //
			ReqPropertyCode:      ReqPropertyCodeError, //
			ReqPropertyRequestID: reqId,                //
		})
		return
	} else {
		Response(w, map[string]interface{}{ //
			ReqPropertyCode:      ReqPropertyCodeOK, //
			ReqPropertyRequestID: reqId,             //
			ReqPropertyUrl:       oauthUrl,
		})
		return
	}
	//http.Redirect(w, r, oauthUrl, http.StatusFound)
}

func twitterLoginExit(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	ctx := appengine.NewContext(r)
	//	log.Infof(ctx, "=======OKK-Z----->")
	twitterObj := GetTwitterManager()
	_, rt, err := twitterObj.OnCallbackSendRequestToken(ctx, r.URL)
	if err != nil {
		Response(w, map[string]interface{}{ //
			"r": "ng", "s": "good", "dev": err.Error(), //
		})
		return
	}
	userMana := GetUserManager()
	userMana.RegistUserFromTwitter(ctx, rt[twitter.ScreenName], rt[twitter.UserID], rt[twitter.OAuthToken], rt[twitter.OAuthTokenSecret])
	id, u, err2 := userMana.LoginUserFromTwitter(ctx, rt[twitter.ScreenName], rt[twitter.UserID], rt[twitter.OAuthToken], rt[twitter.OAuthTokenSecret],
		r.RemoteAddr, r.UserAgent())
	if err2 != nil {
		Response(w, map[string]interface{}{ //
			"r": "ng", "s": "good", "dev": err2.Error(), //
		})
		return
	}
	callbackUrl := r.URL.Query().Get("cb")
	t := "?"
	if strings.Contains(callbackUrl, "?") == true {
		t = "&"
	}
	http.Redirect(w, r, r.URL.Query().Get("cb")+t+"id="+id+"&name="+url.QueryEscape(u.GetUserName()), http.StatusFound)
}
