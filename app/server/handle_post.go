package hello

import (
	"encoding/json"
	//	"fmt"
	"net/http"
	"time"

	"umiuni2d_backend/article"

	"google.golang.org/appengine"

	"umiuni2d_backend/vote"
)

func articleVoteHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")
	//	var v string = r.Method
	if r.Method != "POST" {
		// you must to consider HEAD
		return
	}
	// parse
	var data map[string]interface{}
	json.NewDecoder(r.Body).Decode(&data)
	choiceId := data["choiceId"].(string)
	articleId := data["articleId"].(string)
	//
	//choiceId = "ttt"
	//articleId = "xxx"
	//

	voter := gaevote.NewVoteManager(articleId, []string{choiceId})
	ctx := appengine.NewContext(r)
	err := voter.Vote(ctx, articleId, "des", choiceId)

	if err != nil {
		m := map[string]interface{}{"ret": "ng", "stat": "good", "dev": err.Error(), "dev1": articleId}
		Response(w, m)
	} else {
		m := map[string]interface{}{"ret": "ok", "stat": "good", "dev": ""}
		Response(w, m)
	}
	//
}

func toStringArray(srcs []interface{}) []string {
	var ret []string
	for _, s := range srcs {
		ret = append(ret, s.(string))
	}
	return ret
}

// ------
// postHandler
// ------
func articlePostHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	//w.Header().Add("Access-Control-Allow-Headers", "apikey")
	//	var v string = r.Method
	if r.Method != "POST" {
		// you must to consider HEAD
		return
	}
	ctx := appengine.NewContext(r)
	WriteLog(ctx, "-----> (0)")
	// parse
	var requestPropery map[string]interface{}
	json.NewDecoder(r.Body).Decode(&requestPropery)
	WriteLog(ctx, "-----> (a)")
	cont := requestPropery[ReqPropertyArticleCont].(string)
	title := requestPropery[ReqPropertyArticleTitle].(string)
	WriteLog(ctx, "-----> (b)")
	tags := requestPropery[ReqPropertyArticleTag].([]interface{})
	tag := toStringArray(tags)
	WriteLog(ctx, "-----> (b1)")
	articleId := requestPropery[ReqPropertyArticleId].(string)
	WriteLog(ctx, "-----> (c)")
	reqId := requestPropery[ReqPropertyRequestID].(string)
	state := requestPropery[ReqPropertyArticleState].(string)
	WriteLog(ctx, "-----> (d)")
	userName := requestPropery[ReqPropertyName].(string)

	WriteLog(ctx, "-----> (1)")
	isLogin, _, _ := loginCheckHandler(ctx, r, requestPropery)

	WriteLog(ctx, "-----> (2)")
	if isLogin == false {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeNotFound, ReqPropertyRequestID: reqId})
		return
	}
	//
	//	w.Write()
	//
	WriteLog(ctx, "-----> (4)")

	artMana := GetArtManager()
	//	ctx := appengine.NewContext(r)

	var artObj *article.Article
	var err error = nil
	if len(articleId) == 0 {
		if state == "save" {
			state = "private"
		}
		artObj = artMana.NewArticle(ctx, userName, "")
		artObj.SetTitle(title)
		artObj.SetTags(tag)

		artObj.SetCont(cont)
		artObj.SetState(state)

	} else {
		// arcle
		artObj, err = artMana.GetArticleFromArticleId(ctx, articleId)
		if err != nil {
			Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeWrongID, ReqPropertyRequestID: reqId})
			return
		}
		//
		artObj.SetTitle(title)
		artObj.SetTags(tag)
		artObj.SetCont(cont)
		artObj.SetUpdated(time.Now())
		if state != "save" {
			artObj.SetState(state)
		}
	}
	//

	err = artObj.SaveOnDB(ctx) //datastore.Put(context, key1, &post)
	if err != nil {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeError, ReqPropertyRequestID: reqId})
		return
	}
	if artObj.GetState() == "private" {
		addTagsFromPostIdWithTagSrc(ctx, []string{}, artObj.GetArticleId(), artObj.GetGaeObjectKey(), artObj.GetGaeObjectKey())
	} else {
		addTagsFromPostIdWithTagSrc(ctx, tag, artObj.GetArticleId(), artObj.GetGaeObjectKey(), artObj.GetGaeObjectKey())
	}
	Response(w, map[string]interface{}{
		ReqPropertyCode:         ReqPropertyCodeOK,
		ReqPropertyRequestID:    reqId,                 //
		ReqPropertyArticleId:    artObj.GetArticleId(), //
		ReqPropertyArticleState: artObj.GetState()})
	return
}
