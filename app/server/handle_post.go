package hello

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"umiuni2d_backend/article"

	"google.golang.org/appengine"

	"gaevote"
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

// ------
// postHandler
// ------
func articlePostHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")
	//	var v string = r.Method
	if r.Method != "POST" {
		// you must to consider HEAD
		return
	}
	ctx := appengine.NewContext(r)

	// parse
	var data map[string]interface{}
	json.NewDecoder(r.Body).Decode(&data)
	cont := data[ReqPropertyArticleCont].(string)
	title := data[ReqPropertyArticleTitle].(string)
	tag := data[ReqPropertyArticleTag].(string)
	articleId := data[ReqPropertyArticleId].(string)
	reqId := data[ReqPropertyRequestID].(string)
	state := data[ReqPropertyArticleState].(string)
	userName := data[ReqPropertyName].(string)

	isLogin, _, _ := loginCheckHandler(ctx, r, data)
	if isLogin == false {
		m := map[string]interface{}{"ret": "ng", "stat": "not found", "reqId": reqId}
		Response(w, m)
		return
	}
	//
	//	w.Write()
	//
	artMana := article.NewArticleManager("Article")
	//	ctx := appengine.NewContext(r)

	var artObj *article.Article
	var err error = nil
	if len(articleId) == 0 {
		if state == "save" {
			state = "private"
		}
		artObj = artMana.NewArticle(ctx, userName, "")
		artObj.SetTitle(title)
		artObj.SetTag(tag)

		artObj.SetCont(cont)
		artObj.SetState(state)

	} else {
		// arcle
		artObj, err = artMana.GetArticleFromArticleId(ctx, articleId)
		if err != nil {
			// error
			m := map[string]string{"ret": "ng", "stat": "wrong articleId", "reqId": reqId} //, "dev": v}
			b, _ := json.Marshal(m)
			fmt.Fprintln(w, string(b))
			return
		}
		//
		artObj.SetTitle(title)
		artObj.SetTag(tag)
		artObj.SetCont(cont)
		artObj.SetUpdated(time.Now())
		if state != "save" {
			artObj.SetState(state)
		}
	}
	//

	err = artObj.SaveOnDB(ctx) //datastore.Put(context, key1, &post)
	if err != nil {
		// error
		m := map[string]string{"ret": "ng", "stat": "faied to put", "reqId": reqId} //, "dev": v}
		b, _ := json.Marshal(m)
		fmt.Fprintln(w, string(b))
		return
	}
	if artObj.GetState() == "private" {
		addTagsFromPostIdWithTagSrc(ctx, "", artObj.GetArticleId(), artObj.GetGaeObjectKey(), artObj.GetGaeObjectKey())
	} else {
		addTagsFromPostIdWithTagSrc(ctx, tag, artObj.GetArticleId(), artObj.GetGaeObjectKey(), artObj.GetGaeObjectKey())
	}
	m := map[string]interface{}{
		"ret":       "ok",                  //
		"stat":      "good",                //
		"reqId":     reqId,                 //
		"articleId": artObj.GetArticleId(), //
		"state":     artObj.GetState()}
	b, _ := json.Marshal(m)
	fmt.Fprintln(w, string(b))
	//

	return

}
