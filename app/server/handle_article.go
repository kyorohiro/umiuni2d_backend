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
