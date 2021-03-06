package article

import (
	"encoding/json"
	"time"

	"golang.org/x/net/context"
	"google.golang.org/appengine/datastore"
	//	"google.golang.org/appengine/log"
)

const (
	ArticleStatePublic  = "public"
	ArticleStatePrivate = "private"
	ArticleStateAll     = ""
)

type GaeObjectArticle struct {
	UserName  string
	Title     string `datastore:",noindex"`
	Tag       string `datastore:",noindex"`
	Cont      string `datastore:",noindex"`
	Info      string `datastore:",noindex"`
	State     string
	ParentId  string
	ArticleId string `datastore:",noindex"`
	Created   time.Time
	Updated   time.Time
	SecretKey string `datastore:",noindex"`
}

type Article struct {
	gaeObjectKey *datastore.Key
	gaeObject    *GaeObjectArticle
	kind         string
}

func (obj *Article) GetGaeObjectKind() string {
	return obj.kind
}

func (obj *Article) GetGaeObjectKey() *datastore.Key {
	return obj.gaeObjectKey
}

func (obj *Article) GetUserName() string {
	return obj.gaeObject.UserName
}

func (obj *Article) GetInfo() string {
	return obj.gaeObject.Info
}

func (obj *Article) SetInfo(v string) {
	obj.gaeObject.Info = v
}

func (obj *Article) SetUserName(v string) {
	obj.gaeObject.UserName = v
}

func (obj *Article) GetTitle() string {
	return obj.gaeObject.Title
}

func (obj *Article) SetTitle(v string) {
	obj.gaeObject.Title = v
}

func (obj *Article) GetTags() []string {
	var tags []string
	json.Unmarshal([]byte(obj.gaeObject.Tag), &tags)
	return tags
}

func (obj *Article) SetTags(v []string) {
	if v == nil || len(v) == 0 {
		obj.gaeObject.Tag = ""
	} else {
		b, _ := json.Marshal(v)
		obj.gaeObject.Tag = string(b)
	}
}

func (obj *Article) GetCont() string {
	return obj.gaeObject.Cont
}

func (obj *Article) SetCont(v string) {
	obj.gaeObject.Cont = v
}

func (obj *Article) GetState() string {
	return obj.gaeObject.State
}

func (obj *Article) SetState(v string) {
	obj.gaeObject.State = v
}

func (obj *Article) GetParentId() string {
	return obj.gaeObject.ParentId
}

func (obj *Article) SetParentId(v string) {
	obj.gaeObject.ParentId = v
}

func (obj *Article) GetArticleId() string {
	return obj.gaeObject.ArticleId
}

func (obj *Article) GetCreated() time.Time {
	return obj.gaeObject.Created
}

func (obj *Article) GetUpdated() time.Time {
	return obj.gaeObject.Updated
}

func (obj *Article) SetUpdated(v time.Time) {
	obj.gaeObject.Updated = v
}

//
//
//
//
type ArticleManager struct {
	kindArticle    string
	limitOfFinding int
}

func (obj *Article) SaveOnDB(ctx context.Context) error {
	_, err := datastore.Put(ctx, obj.gaeObjectKey, obj.gaeObject)
	return err
}

func (obj *ArticleManager) newCursorFromSrc(cursorSrc string) *datastore.Cursor {
	c1, e := datastore.DecodeCursor(cursorSrc)
	if e != nil {
		return nil
	} else {
		return &c1
	}
}

func (obj *ArticleManager) makeCursorSrc(founds *datastore.Iterator) string {
	c, e := founds.Cursor()
	if e == nil {
		return c.String()
	} else {
		return ""
	}
}

func (obj *ArticleManager) GetArticleFromArticleId(ctx context.Context, articleId string) (*Article, error) {
	k := obj.NewGaeObjectKey(ctx, articleId)
	var a GaeObjectArticle
	err := datastore.Get(ctx, k, &a)
	if err != nil {
		return nil, err
	}
	return obj.NewArticleFromGaeObject(ctx, k, &a), nil
}

/*
- kind: Article
  properties:
  - name: UserName
  - name: ParentId
  - name: Updated
    direction: asc

- kind: Article
  properties:
  - name: UserName
  - name: ParentId
  - name: Updated
    direction: desc

- kind: Article
  properties:
  - name: UserName
  - name: ParentId
  - name: State
  - name: Updated
    direction: desc

https://cloud.google.com/appengine/docs/go/config/indexconfig#updating_indexes
*/
func (obj *ArticleManager) FindArticleFromUserName(ctx context.Context, userName string, parentId string, state string, cursorSrc string) ([]*Article, string, string) {
	q := datastore.NewQuery(obj.kindArticle).
		Filter("UserName =", userName). ////
		Filter("ParentId =", parentId)
	if state != "" {
		q = q.Filter("State =", ArticleStatePublic) //
	}
	q = q.Order("-Updated").Limit(obj.limitOfFinding)
	return obj.FindArticleFromQuery(ctx, q, cursorSrc)
}

/*
- kind: Article
  properties:
  - name: State
  - name: ParentId
  - name: Updated
    direction: asc

- kind: Article
  properties:
  - name: State
  - name: ParentId
  - name: Updated
    direction: desc

https://cloud.google.com/appengine/docs/go/config/indexconfig#updating_indexes
*/
func (obj *ArticleManager) FindArticleWithNewOrder(ctx context.Context, parentId string, cursorSrc string) ([]*Article, string, string) {
	q := datastore.NewQuery(obj.kindArticle).Filter("State =", ArticleStatePublic).Filter("ParentId =", parentId).Order("-Updated").Limit(obj.limitOfFinding)
	return obj.FindArticleFromQuery(ctx, q, cursorSrc)
}

func (obj *ArticleManager) FindArticleFromQuery(ctx context.Context, q *datastore.Query, cursorSrc string) ([]*Article, string, string) {
	cursor := obj.newCursorFromSrc(cursorSrc)
	if cursor != nil {
		q = q.Start(*cursor)
	}
	founds := q.Run(ctx)

	var retUser []*Article

	var cursorNext string = ""
	var cursorOne string = ""

	for i := 0; ; i++ {
		var d GaeObjectArticle
		key, err := founds.Next(&d)
		if err != nil || err == datastore.Done {
			break
		} else {
			retUser = append(retUser, obj.NewArticleFromGaeObject(ctx, key, &d))
		}
		if i == 0 {
			cursorOne = obj.makeCursorSrc(founds)
		}
	}
	cursorNext = obj.makeCursorSrc(founds)
	return retUser, cursorOne, cursorNext
}
