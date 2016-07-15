package hello

import (
	"encoding/json"
	"net/http"
	"net/url"

	"google.golang.org/appengine"
)

func twitterLoginEntry(w http.ResponseWriter, r *http.Request) {
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
