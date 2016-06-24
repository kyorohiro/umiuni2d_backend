package article

import (
	"crypto/sha1"
	"encoding/base64"
	"encoding/binary"
	"fmt"
	"strconv"
	"time"

	"crypto/rand"

	"golang.org/x/net/context"
	"google.golang.org/appengine/datastore"
)

func NewArticleManager(kindArticle string, limitOfFinding int) *ArticleManager {
	ret := new(ArticleManager)
	ret.kindArticle = kindArticle
	ret.limitOfFinding = limitOfFinding
	return ret
}

func (obj *ArticleManager) NewArticleFromGaeObject(ctx context.Context, gaeKey *datastore.Key, gaeObj *GaeObjectArticle) *Article {
	ret := new(Article)
	ret.gaeObject = gaeObj
	ret.gaeObjectKey = gaeKey
	ret.kind = obj.kindArticle
	return ret
}

func (obj *ArticleManager) NewArticle(ctx context.Context, userName string, parentId string) *Article {
	created := time.Now()
	var secretKey string
	var artKey string
	var key *datastore.Key
	var art GaeObjectArticle
	for {
		secretKey = obj.makeRandomId() + obj.makeRandomId()
		artKey = obj.makeArticleKey(userName, parentId, created, secretKey)
		key = obj.NewGaeObjectKey(ctx, artKey)
		err := datastore.Get(ctx, key, &art)
		if err != nil {
			break
		}
	}
	//
	ret := new(Article)
	ret.kind = obj.kindArticle
	ret.gaeObject = &art
	ret.gaeObjectKey = key
	ret.gaeObject.UserName = userName
	ret.gaeObject.ParentId = parentId
	ret.gaeObject.Created = created
	ret.gaeObject.Updated = created
	ret.gaeObject.ArticleId = artKey
	//
	return ret
}

func (obj *ArticleManager) NewGaeObjectKey(ctx context.Context, articleId string) *datastore.Key {
	return datastore.NewKey(ctx, obj.kindArticle, articleId, 0, nil)
}

func (obj *ArticleManager) makeArticleKey(userName string, parentId string, created time.Time, secretKey string) string {
	hashKey := obj.hashStr(fmt.Sprintf("v1e%s%s%s%s%d", secretKey, userName, userName, parentId, created.UnixNano()))
	userName64 := base64.StdEncoding.EncodeToString([]byte(userName))
	return "v1e" + hashKey + parentId + userName64
}

func (obj *ArticleManager) hash(v string) string {
	sha1Obj := sha1.New()
	sha1Obj.Write([]byte(v))
	return string(sha1Obj.Sum(nil))
}

func (obj *ArticleManager) hashStr(v string) string {
	sha1Obj := sha1.New()
	sha1Obj.Write([]byte(v))
	return string(base64.StdEncoding.EncodeToString(sha1Obj.Sum(nil)))
}

func (obj *ArticleManager) makeRandomId() string {
	var n uint64
	binary.Read(rand.Reader, binary.LittleEndian, &n)
	return strconv.FormatUint(n, 36)
}
