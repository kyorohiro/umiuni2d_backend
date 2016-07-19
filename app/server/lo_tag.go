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

func addTagsFromPostIdWithTagSrc(ctx context.Context, tagList []string, subTag string, optTag string, articleId string, articleKey *datastore.Key, parent *datastore.Key) error {
	//
	r, _, _ := GetTagManager().FindTagFromTargetId(ctx, articleId, "")
	for _, v := range r {
		datastore.Delete(ctx, v.GetGaeObjectKey())
	}
	//
	for _, v := range tagList {
		tag := GetTagManager().NewTag(ctx, v, subTag, optTag, "", articleId)
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

	tag := data[ReqPropertyArticleTag].(string)
	propRequestId := data[ReqPropertyRequestID].(string)
	cursor := data[ReqPropertyCursor].(string)

	arts, cO, cN, err := findArticleFromTag(ctx, tag, cursor)
	//
	if err != nil {
		Response(w, map[string]interface{}{ //
			ReqPropertyCode:      ReqPropertyCodeError, //
			ReqPropertyRequestID: propRequestId})
		return
	}
	// requestPropery
	findArticleResponse(w, data, *arts, cO, cN, false)
}
