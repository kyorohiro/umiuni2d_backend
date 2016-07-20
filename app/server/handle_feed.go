package hello

import (
	"encoding/json"
	"net/http"

	"umiuni2d_backend/article"

	//"strings"

	"google.golang.org/appengine"
)

//
//
//
func articleFindWithNewOrderHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	//w.Header().Add("Access-Control-Allow-Headers", "apikey")

	if r.Method != "POST" {
		// you must to consider HEAD
		return
	}

	var requestPropery map[string]interface{}
	json.NewDecoder(r.Body).Decode(&requestPropery)
	propCursorSrc := getStringFromProp(requestPropery, ReqPropertyCursor, "")
	parentId := getStringFromProp(requestPropery, ReqPropertyParentID, "")
	haveContInResponse := getBoolFromProp(requestPropery, ReqPropertyHaveContent, false)

	ctx := appengine.NewContext(r)
	u, cN, cO := GetArtManager().FindArticleWithNewOrder(ctx, parentId, propCursorSrc)
	findArticleResponse(w, requestPropery, u, cN, cO, haveContInResponse)
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
	var requestPropery map[string]interface{}
	json.NewDecoder(r.Body).Decode(&requestPropery)
	propUserName := requestPropery[ReqPropertyName].(string)
	//	propRequestId := requestPropery[ReqPropertyRequestID].(string)
	propCursorSrc := requestPropery[ReqPropertyCursor].(string)
	u, o, cursorNext := GetArtManager().FindArticleFromUserName(ctx, propUserName, "", article.ArticleStatePublic, propCursorSrc)
	//
	findArticleResponse(w, requestPropery, u, o, cursorNext, false)
}

// todo
func articlefindFromMeHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")
	ctx := appengine.NewContext(r)
	WriteLog(ctx, "-----> (1)")
	if r.Method != "POST" {
		// you must to consider HEAD
		return
	}

	WriteLog(ctx, "-----> (1-1)")
	// parse
	var requestPropery map[string]interface{}
	json.NewDecoder(r.Body).Decode(&requestPropery)
	WriteLog(ctx, "-----> (1-2)")
	//propUserName := requestPropery[ReqPropertyName].(string)
	propRequestId := requestPropery[ReqPropertyRequestID].(string)
	propCursorSrc := requestPropery[ReqPropertyCursor].(string)

	WriteLog(ctx, "-----> (2)")
	//
	//
	isLogin, atk, _ := loginCheckHandler(ctx, r, requestPropery)

	WriteLog(ctx, "-----> (3)")
	if isLogin == false {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeNotFound, ReqPropertyRequestID: propRequestId})
		return
	}
	//
	//
	u, o, cursorNext := GetArtManager().FindArticleFromUserName(ctx, atk.GetUserName(), "", article.ArticleStateAll, propCursorSrc)
	//
	findArticleResponse(w, requestPropery, u, o, cursorNext, false)
}

func findArticleResponse(w http.ResponseWriter, requestPropery map[string]interface{}, u []*article.Article, cursorOne string, cursorNext string, includeCont bool) {
	var articleIdList []interface{}
	for _, v := range u {
		cont := v.GetCont()
		infoLen := 100
		if len(cont) < infoLen {
			infoLen = len(cont)
		}

		w := map[string]interface{}{
			ReqPropertyArticleId:    v.GetArticleId(),
			ReqPropertyName:         v.GetUserName(),
			ReqPropertyArticleTitle: v.GetTitle(),
			ReqPropertyArticleState: v.GetState(),
			ReqPropertyArticleTag:   v.GetTags(),
			ReqPropertyArticleInfo:  v.GetCont()[0:infoLen],
			ReqPropertyUpdated:      v.GetUpdated().UnixNano() / 1000,
			ReqPropertyCreated:      v.GetCreated().UnixNano() / 1000}
		if includeCont {
			w[ReqPropertyArticleCont] = v.GetCont()
		}

		articleIdList = append(articleIdList, w)
	}

	//
	// ok
	m := map[string]interface{}{
		ReqPropertyCode:       ReqPropertyCodeOK,
		ReqPropertyRequestID:  requestPropery[ReqPropertyRequestID].(string),
		ReqPropertyArticles:   articleIdList,
		ReqPropertyCursorNext: cursorNext,
	}
	Response(w, m)
}
