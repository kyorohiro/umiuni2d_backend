package tag

import (
	"time"

	"golang.org/x/net/context"
	"google.golang.org/appengine/datastore"
)

type GaeObjectTag struct {
	MainTag  string
	SubTag   string
	OptTag   string
	OwnerId  string
	TargetId string
	Updated  time.Time
	Priority int
}

type TagManager struct {
	kind string
}

type Tag struct {
	gaeObject    *GaeObjectTag
	gaeObjectKey *datastore.Key
	kind         string
}

func NewTagManager(kind string) *TagManager {
	ret := new(TagManager)
	ret.kind = kind
	return ret
}

func (obj *TagManager) NewTag(ctx context.Context, mainTag string, subTag string, optTag string, ownerId string, targetId string) *Tag {
	ret := new(Tag)
	ret.gaeObject = new(GaeObjectTag)
	ret.gaeObject.MainTag = mainTag
	ret.gaeObject.SubTag = subTag
	ret.gaeObject.OptTag = optTag
	ret.gaeObject.OwnerId = ownerId
	ret.gaeObject.TargetId = targetId
	ret.gaeObjectKey = obj.NewTagKey(ctx, mainTag, subTag, optTag, ownerId, targetId)
	ret.gaeObject.Updated = time.Now()
	return ret
}

func (obj *TagManager) NewTagKey(ctx context.Context, mainTag string, subTag string, optTag string, ownerId string, targetId string) *datastore.Key {
	ret := datastore.NewKey(ctx, obj.kind, ""+mainTag+","+subTag+","+optTag+","+ownerId+","+targetId, 0, nil)
	return ret
}

func (obj *TagManager) NewTagFromGaeObject(ctx context.Context, gaeKey *datastore.Key, gaeObj *GaeObjectTag) *Tag {
	ret := new(Tag)
	ret.gaeObject = gaeObj
	ret.gaeObjectKey = gaeKey
	ret.kind = obj.kind
	return ret
}

func (obj *TagManager) FindTagFromMainTag(ctx context.Context, mainTag string, cursorSrc string) ([]*Tag, string, string) {
	q := datastore.NewQuery(obj.kind).Filter("MainTag =", mainTag).Order("-Updated")
	return obj.FindTagFromQuery(ctx, q, cursorSrc)
}

func (obj *TagManager) FindTagFromSubTag(ctx context.Context, mainTag string, subTag string, cursorSrc string) ([]*Tag, string, string) {
	q := datastore.NewQuery(obj.kind).Filter("MainTag =", mainTag).Filter("SubTag =", subTag).Order("-Updated")
	return obj.FindTagFromQuery(ctx, q, cursorSrc)
}

func (obj *TagManager) FindTagFromTag(ctx context.Context, mainTag string, subTag string, optTag string, cursorSrc string) ([]*Tag, string, string) {
	q := datastore.NewQuery(obj.kind).Filter("MainTag =", mainTag).Filter("SubTag =", subTag).Filter("OptTag =", optTag).Order("-Updated")
	return obj.FindTagFromQuery(ctx, q, cursorSrc)
}

func (obj *TagManager) FindTagFromTargetId(ctx context.Context, targetTag string, cursorSrc string) ([]*Tag, string, string) {
	q := datastore.NewQuery(obj.kind).Filter("TargetId =", targetTag).Order("-Updated")
	return obj.FindTagFromQuery(ctx, q, cursorSrc)
}

func (obj *TagManager) FindTagFromOwnerId(ctx context.Context, targetTag string, cursorSrc string) ([]*Tag, string, string) {
	q := datastore.NewQuery(obj.kind).Filter("OwnerId =", targetTag).Order("-Updated")
	return obj.FindTagFromQuery(ctx, q, cursorSrc)
}

func (obj *TagManager) FindTagFromQuery(ctx context.Context, q *datastore.Query, cursorSrc string) ([]*Tag, string, string) {
	cursor := obj.newCursorFromSrc(cursorSrc)
	if cursor != nil {
		q = q.Start(*cursor)
	}
	founds := q.Run(ctx)

	var retUser []*Tag

	var cursorNext string = ""
	var cursorOne string = ""

	for i := 0; ; i++ {
		var d GaeObjectTag
		key, err := founds.Next(&d)
		if err != nil || err == datastore.Done {
			break
		} else {
			retUser = append(retUser, obj.NewTagFromGaeObject(ctx, key, &d))
		}
		if i == 0 {
			cursorOne = obj.makeCursorSrc(founds)
		}
	}
	cursorNext = obj.makeCursorSrc(founds)
	return retUser, cursorOne, cursorNext
}

func (obj *TagManager) newCursorFromSrc(cursorSrc string) *datastore.Cursor {
	c1, e := datastore.DecodeCursor(cursorSrc)
	if e != nil {
		return nil
	} else {
		return &c1
	}
}

func (obj *TagManager) makeCursorSrc(founds *datastore.Iterator) string {
	c, e := founds.Cursor()
	if e == nil {
		return c.String()
	} else {
		return ""
	}
}
