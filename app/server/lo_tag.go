package hello

import (
	"encoding/json"
	"net/http"
	"strings"

	"umiuni2d_backend/article"
	"umiuni2d_backend/tag"

	"golang.org/x/net/context"
	"google.golang.org/appengine"
	"google.golang.org/appengine/datastore"
)

func addTagsFromPostIdWithTagSrc(ctx context.Context, tagSrc string, articleId string, articleKey *datastore.Key, parent *datastore.Key) error {
	//
	r, _, _ := GetTagManager().FindTagFromTargetId(ctx, articleId, "")
	for _, v := range r {
		datastore.Delete(ctx, v.GetGaeObjectKey())
	}
	//
	tagList := extractTag(tagSrc)
	for _, v := range tagList {
		tag := GetTagManager().NewTag(ctx, v, "", "", "", articleId)
		tag.SaveOnDB(ctx)
	}
	return nil
}

func extractTag(tagSrc string) []string {
	tagSrc = strings.Replace(tagSrc, "\r\n", " ", -1)
	tagSrc = strings.Replace(tagSrc, "\n", " ", -1)
	tagSrc = strings.Replace(tagSrc, "\t", " ", -1)

	return strings.Split(tagSrc, " ")
}

func findTagFromArticleObj(ctx context.Context, articleId string) ([]*tag.Tag, string, string) {
	return GetTagManager().FindTagFromMainTag(ctx, articleId, "")
}

func findArticleFromTag(ctx context.Context, tag string, cursor string) (*[]*article.Article, string, string, error) {
	//datastore.Query *
	var articleList []*article.Article

	tags, co, cn := GetTagManager().FindTagFromTag(ctx, tag, "", "", cursor)

	//
	artMana := GetArtManager()

	for _, t := range tags {
		a, e := artMana.GetArticleFromArticleId(ctx, t.GetTargetId())
		if e == nil {
			articleList = append(articleList, a)
		}
	}

	return &articleList, co, cn, nil
}

func articleFindFromTagHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")
	ctx := appengine.NewContext(r)
	//	var v string = r.Method
	if r.Method != "POST" {
		// you must to consider HEAD
		return
	}

	var data map[string]interface{}
	json.NewDecoder(r.Body).Decode(&data)

	tag := data["tag"].(string)
	reqId := data["reqId"].(string)
	cursor := data["cursor"].(string)

	arts, cO, cN, err := findArticleFromTag(ctx, tag, cursor)
	//
	if err != nil {
		m := map[string]interface{}{"ret": "ng", "stat": "error", "reqId": reqId}
		Response(w, m)
		return
	}
	var articleIdList []interface{}
	for _, v := range *arts {
		articleIdList = append(articleIdList, map[string]interface{}{
			"id":      v.GetArticleId(),
			"name":    v.GetUserName(),
			"title":   v.GetTitle(),
			"updated": v.GetUpdated().UnixNano() / 1000,
			"created": v.GetCreated().UnixNano() / 1000})
	}
	//
	// ok
	m := map[string]interface{}{ //
		"ret": "ok", "stat": "good", "reqId": reqId, //
		"arts": articleIdList, "dev": len(*arts), //
		"cursor_forward": cN,
		"cursor_one":     cO}
	Response(w, m)
}
