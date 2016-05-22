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

type GaeObjectArticle struct {
	UserName  string
	Title     string
	SubTitle  string
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
}

type ArticleManager struct {
	kindArticle string
}

func NewArticleManager(kindArticle string) *ArticleManager {
	ret := new(ArticleManager)
	ret.kindArticle = kindArticle
	return ret
}

func (obj *ArticleManager) NewArticle(ctx context.Context, userName string, parentId string) *Article {
	created := time.Now()
	var secretKey string
	var artKey string
	var key *datastore.Key
	var art GaeObjectArticle
	for {
		secretKey = obj.MakeRandomId()
		artKey = obj.makeArticleKey(userName, parentId, created, secretKey)
		key = obj.NewGaeObjectKey(ctx, artKey)
		err := datastore.Get(ctx, key, &art)
		if err == nil {
			break
		}
	}
	//
	ret := new(Article)
	ret.gaeObject = &art
	ret.gaeObjectKey = key
	ret.gaeObject.UserName = userName
	ret.gaeObject.ParentId = parentId
	ret.gaeObject.Created = created
	ret.gaeObject.Updated = created
	//
	return ret
}

func (obj *ArticleManager) NewGaeObjectKey(ctx context.Context, articleId string) *datastore.Key {
	return datastore.NewKey(ctx, obj.kindArticle, articleId, 0, nil)
}

func (obj *ArticleManager) makeArticleKey(userName string, parentId string, created time.Time, secretKey string) string {
	hashKey := obj.hash(fmt.Sprintf("v1e%s%s%s%s%d", secretKey, userName, userName, parentId, created.UnixNano()))
	userName64 := base64.StdEncoding.EncodeToString([]byte(userName))
	return "v1e" + hashKey + parentId + userName64
}

func (obj *ArticleManager) hash(v string) string {
	sha1Obj := sha1.New()
	sha1Obj.Write([]byte(v))
	return string(sha1Obj.Sum(nil))
}

func (obj *ArticleManager) MakeRandomId() string {
	var n uint64
	binary.Read(rand.Reader, binary.LittleEndian, &n)
	return strconv.FormatUint(n, 36)
}
