package hello

import (
	"fmt"
	"net/http"

	"encoding/json"

	"google.golang.org/appengine"
	"google.golang.org/appengine/blobstore"
)

func fileOnUploadedHandler(w http.ResponseWriter, r *http.Request) {
	ctx := appengine.NewContext(r)
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")

	item, opt, err := GetBlobManager().HandleUploaded(ctx, r)

	if err != nil {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeError, ReqPropertyRequestID: opt})
		return
	} else {
		Response(w, map[string]interface{}{ //
			ReqPropertyCode:      ReqPropertyCodeOK, //
			ReqPropertyRequestID: opt,               //
			ReqPropertyBlobKey:   item.GetBlobKey()})
	}
}

func fileGetRequestIdHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")
	ctx := appengine.NewContext(r)
	if r.Method != "POST" {
		// you must to consider HEAD
		return
	}

	//
	//
	var data map[string]interface{}
	json.NewDecoder(r.Body).Decode(&data)
	reqId := data[ReqPropertyRequestID].(string)
	articleId := data[ReqPropertyArticleId].(string)

	//
	//
	isLogin, accessTokenObj, _ := loginCheckHandler(ctx, r, data)
	if isLogin == false {
		return
	}
	dir := ""
	name := ""

	if articleId == "meicon" {
		dir = "/user/" + accessTokenObj.GetUserName()
		name = articleId
	} else {
		dir = "/post/" + articleId
		name = "" //makeRandomId()
	}

	uploaded, err := GetBlobManager().MakeRequestUrl(ctx, dir, name, reqId)

	if err != nil {
		return
	}

	//
	//WriteLog(ctx, "====> bef uploaded"+uploaded)
	// ok
	m := map[string]interface{}{ReqPropertyCode: ReqPropertyCodeOK, //
		ReqPropertyRequestID: reqId, ReqPropertyUrl: uploaded}
	Response(w, m)
}

func fileDeleteHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")
	ctx := appengine.NewContext(r)
	if r.Method != "POST" {
		// you must to consider HEAD
		return
	}

	//
	//
	var data map[string]interface{}
	json.NewDecoder(r.Body).Decode(&data)
	reqId := data[ReqPropertyRequestID].(string)
	articleId := data[ReqPropertyArticleId].(string)
	fileName := data[ReqPropertyFileName].(string)

	//
	//
	isLogin, _, _ := loginCheckHandler(ctx, r, data)
	if isLogin == false {
		return
	}
	dir := "/post/" + articleId
	name := fileName

	uploaded, err := GetBlobManager().GetBlobItem(ctx, dir, name)
	if err == nil {
		uploaded.DeleteFromDB(ctx)
	}

	Response(w, map[string]interface{}{"ret": "ok", "stat": "good", "reqId": reqId})
}

func fileGetHandle(w http.ResponseWriter, r *http.Request) {
	blobstore.Send(w, appengine.BlobKey(r.FormValue("blobKey")))
}

func fileFindFromArticleHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")
	ctx := appengine.NewContext(r)

	if r.Method != "POST" {
		return
	}

	// parse
	var data map[string]interface{}
	json.NewDecoder(r.Body).Decode(&data)
	reqId := data[ReqPropertyRequestID].(string)
	cursorSrc := data[ReqPropertyCursor].(string)
	articleId := data[ReqPropertyArticleId].(string)

	bs, _, cursorNext := GetBlobManager().FindBlobItemFromParent(ctx, "/post/"+articleId, cursorSrc)

	//
	var articleIdList []interface{}
	for _, v := range bs {
		articleIdList = append(articleIdList, map[string]interface{}{
			"blobKey": v.GetBlobKey(),
			"name":    v.GetName(),
		})
	}

	//
	// ok
	m := map[string]interface{}{
		"ret":            "ok",
		"stat":           "good",
		"reqId":          reqId,
		"items":          articleIdList,
		"cursor_forward": cursorNext,
	}
	b, _ := json.Marshal(m)
	fmt.Fprintln(w, string(b))
}
