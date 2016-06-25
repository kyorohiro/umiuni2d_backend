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

	// parse
	var requestPropery map[string]interface{}
	json.NewDecoder(r.Body).Decode(&requestPropery)
	//	reqId := requestPropery["reqId"].(string)
	propCursorSrc := requestPropery["cursor"].(string)

	ctx := appengine.NewContext(r)
	u, cN, cO := GetArtManager().FindArticleWithNewOrder(ctx, "", propCursorSrc)
	findArticleResponse(w, requestPropery, u, cN, cO)
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
	u, o, cursorNext := GetArtManager().FindArticleFromUserName(ctx, propUserName, "", propCursorSrc)
	//
	findArticleResponse(w, requestPropery, u, o, cursorNext)
}

func findArticleResponse(w http.ResponseWriter, requestPropery map[string]interface{}, u []*article.Article, cursorOne string, cursorNext string) {
	var articleIdList []interface{}
	for _, v := range u {
		cont := v.GetCont()
		infoLen := 100
		if len(cont) < infoLen {
			infoLen = len(cont)
		}

		articleIdList = append(articleIdList, map[string]interface{}{
			ReqPropertyArticleId:    v.GetArticleId(),
			ReqPropertyName:         v.GetUserName(),
			ReqPropertyArticleTitle: v.GetTitle(),
			ReqPropertyArticleState: v.GetState(),
			ReqPropertyArticleTag:   v.GetTags(),
			ReqPropertyArticleInfo:  v.GetCont()[0:infoLen],
			ReqPropertyUpdated:      v.GetUpdated().UnixNano() / 1000,
			ReqPropertyCreated:      v.GetCreated().UnixNano() / 1000})
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
