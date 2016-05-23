package article

import (
	"time"

	"golang.org/x/net/context"
	"google.golang.org/appengine/datastore"
)

type GaeObjectArticle struct {
	UserName  string
	Title     string
	Tag       string
	Cont      string
	State     string
	ParentId  string
	ArticleId string
	Created   time.Time
	Updated   time.Time
	SecretKey string
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

func (obj *Article) SetUserName(v string) {
	obj.gaeObject.UserName = v
}

func (obj *Article) GetTitle() string {
	return obj.gaeObject.Title
}

func (obj *Article) SetTitle(v string) {
	obj.gaeObject.Title = v
}

func (obj *Article) GetTag() string {
	return obj.gaeObject.Tag
}

func (obj *Article) SetTag(v string) {
	obj.gaeObject.Tag = v
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
	kindArticle string
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

func (obj *ArticleManager) GetArticleFromUserName(ctx context.Context, userName string, cursorSrc string) ([]*Article, string, string) {
	q := datastore.NewQuery(obj.kindArticle).Filter("UserName =", userName).Limit(20)
	return obj.GetArticleFromQuery(ctx, q, cursorSrc)
}

func (obj *ArticleManager) GetArticleWithNewOrder(ctx context.Context, userName string, cursorSrc string) ([]*Article, string, string) {
	q := datastore.NewQuery(obj.kindArticle).Filter("State =", "public").Order("-Updated").Limit(20)
	return obj.GetArticleFromQuery(ctx, q, cursorSrc)
}

func (obj *ArticleManager) GetArticleFromQuery(ctx context.Context, q *datastore.Query, cursorSrc string) ([]*Article, string, string) {
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
