package hello

import (
	"encoding/json"
	// "fmt"
	"net/http"

	"google.golang.org/appengine"
)

//----
// myArticleHandler
//---
func articleGetHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")

	if r.Method != "POST" {
		// you must to consider HEAD
		return
	}

	// parse
	var requestPropery map[string]interface{}
	json.NewDecoder(r.Body).Decode(&requestPropery)
	propRequestId := requestPropery[ReqPropertyRequestID].(string)
	propArticleId := requestPropery[ReqPropertyArticleId].(string)

	// arcle
	ctx := appengine.NewContext(r)
	artObj, e := GetArtManager().GetArticleFromArticleId(ctx, propArticleId)
	if e != nil {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeNotFound, ReqPropertyRequestID: propRequestId})
		return
	}
	//
	//
	cont := artObj.GetCont()
	infoLen := 100
	if len(cont) < infoLen {
		infoLen = len(cont)
	}
	//
	m := map[string]interface{}{
		ReqPropertyCode:         ReqPropertyCodeOK,
		ReqPropertyRequestID:    propRequestId,
		ReqPropertyArticleId:    artObj.GetArticleId(),
		ReqPropertyName:         artObj.GetUserName(),
		ReqPropertyArticleTitle: artObj.GetTitle(),
		ReqPropertyArticleState: artObj.GetState(),
		ReqPropertyArticleTag:   artObj.GetTags(),
		ReqPropertyArticleInfo:  artObj.GetCont()[0:infoLen],
		ReqPropertyUpdated:      artObj.GetUpdated().UnixNano() / 1000,
		ReqPropertyCreated:      artObj.GetCreated().UnixNano() / 1000,
		ReqPropertyArticleCont:  artObj.GetCont(),
	}
	Response(w, m)
}

// ------
// commentHandler
// ------
func articleGetCommentsHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")
	// todo
	ctx := appengine.NewContext(r)
	WriteLog(ctx, "/article/get_comment (1)")
	if r.Method != "POST" {
		return
	}
	var data map[string]interface{}
	json.NewDecoder(r.Body).Decode(&data)

	//
	// get post
	//	context := appengine.NewContext(r)
	comments, sCur, eCur := GetArtManager().FindArticleWithNewOrder(ctx, data["articleId"].(string), data["eCur"].(string))

	var articleIdList []interface{}
	for _, v := range comments {
		articleIdList = append(articleIdList, map[string]interface{}{
			"name":    v.GetUserName(),
			"cont":    v.GetCont(),
			"updated": v.GetUpdated().UnixNano() / 1000,
			"created": v.GetCreated().UnixNano() / 1000})
	}
	//
	m := map[string]interface{}{"ret": "ok", "stat": "good", //
		"reqId":    data["reqId"].(string), //
		"comments": articleIdList,
		"sCur":     sCur,
		"eCur":     eCur}
	Response(w, m)
	return

}

// ------
// commentHandler
// ------
func articlePostCommentHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")
	if r.Method != "POST" {
		return
	}

	//
	//
	var data map[string]interface{}
	json.NewDecoder(r.Body).Decode(&data)
	articleId := data[ReqPropertyArticleId].(string)
	reqId := data[ReqPropertyRequestID].(string)
	cont := data[ReqPropertyArticleCont].(string)
	state := data[ReqPropertyArticleState].(string)

	//
	// login check
	ctx := appengine.NewContext(r)
	isLogin, accessTokenObj, _ := loginCheckHandler(ctx, r, data)
	if isLogin == false {
		m := map[string]interface{}{"ret": "ng", "stat": "need login", "reqId": reqId} //, "dev": v}
		Response(w, m)
		return
	}

	//
	// get post
	artObj, e := GetArtManager().GetArticleFromArticleId(ctx, articleId)
	if e != nil {
		m := map[string]interface{}{"ret": "ng", "stat": "wrong articleId", "reqId": reqId} //, "dev": v}
		Response(w, m)
		return
	}

	commentObj := GetArtManager().NewArticle(ctx, accessTokenObj.GetUserName(), articleId)
	commentObj.SetCont(cont)
	commentObj.SetState(state)
	err2 := commentObj.SaveOnDB(ctx)

	if err2 != nil {
		// error
		m := map[string]interface{}{"ret": "ng", "stat": "faied to put", "reqId": data["reqId"].(string)} //, "dev": v}
		Response(w, m)
		return
	}
	//
	//
	m := map[string]interface{}{"ret": "ok", "stat": "good", "reqId": data["reqId"].(string), "articleId": artObj.GetArticleId()}
	Response(w, m)
	return

}
