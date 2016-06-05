package hello

import (
	"encoding/json"
	"net/http"

	"google.golang.org/appengine"
)

//
//
//
func articleGetWithNewOrderHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")

	if r.Method != "POST" {
		// you must to consider HEAD
		return
	}

	// parse
	var data map[string]interface{}
	json.NewDecoder(r.Body).Decode(&data)
	reqId := data["reqId"].(string)
	cursorSrc := data["cursor"].(string)

	ctx := appengine.NewContext(r)
	u, cN, cO := GetArtManager().FindArticleWithNewOrder(ctx, "", cursorSrc)

	//
	var articleIdList []interface{}
	for _, v := range u {
		articleIdList = append(articleIdList, map[string]interface{}{
			"id":      v.GetArticleId(),
			"name":    v.GetUserName(),
			"title":   v.GetTitle(),
			"updated": v.GetUpdated().UnixNano() / 1000,
			"created": v.GetCreated().UnixNano() / 1000})
	}
	//
	// ok
	m := map[string]interface{}{
		"ret": "ok", "stat": "good",
		"reqId":          reqId,
		"cursor_forward": cN,
		"cursor_one":     cO,
		"arts":           articleIdList}
	Response(w, m)
}

//----
// myArticleHandler
//---
func meGetInfoHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")

	if r.Method != "POST" {
		// you must to consider HEAD
		return
	}
	ctx := appengine.NewContext(r)
	// parse
	var data map[string]interface{}
	json.NewDecoder(r.Body).Decode(&data)
	reqId := data[ReqPropertyRequestID].(string)

	// find user
	isLogin, accessTokenObj, _ := loginCheckHandler(ctx, r)
	if isLogin == false {
		m := map[string]interface{}{"ret": "ng", "stat": "need to login", "reqId": reqId}
		Response(w, m)
		return
	}

	userObj, err := GetUserManager().FindUserFromUserName(ctx, accessTokenObj.GetUserName())
	if err != nil {
		m := map[string]interface{}{"ret": "ng", "stat": "not found user", "reqId": reqId}
		Response(w, m)
		return
	}

	//
	// ok
	m := map[string]interface{}{
		"ret":   "ok",
		"stat":  "good",
		"name":  userObj.GetUserName(),
		"mail":  userObj.GetMail(),
		"reqId": reqId,
	}
	Response(w, m)
}

func articlefindFromUserNameHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")

	if r.Method != "POST" {
		// you must to consider HEAD
		return
	}
	ctx := appengine.NewContext(r)
	// parse
	var data map[string]interface{}
	json.NewDecoder(r.Body).Decode(&data)
	userName := data[ReqPropertyName].(string)
	reqId := data[ReqPropertyRequestID].(string)
	cursorSrc := data[ReqPropertyCursor].(string)
	u, _, cursorNext := GetArtManager().FindArticleFromUserName(ctx, userName, "", cursorSrc)
	//
	var articleIdList []interface{}
	for _, v := range u {
		articleIdList = append(articleIdList, map[string]interface{}{
			"id":      v.GetArticleId(),
			"name":    v.GetUserName(),
			"title":   v.GetTitle(),
			"state":   v.GetState(),
			"updated": v.GetUpdated().UnixNano() / 1000,
			"created": v.GetCreated().UnixNano() / 1000})
	}

	//
	// ok
	m := map[string]interface{}{
		"ret":            "ok",
		"stat":           "good",
		"reqId":          reqId,
		"arts":           articleIdList,
		"cursor_forward": cursorNext,
	}
	Response(w, m)
}
