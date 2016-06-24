package hello

import (
	"encoding/json"
	"fmt"
	"net/http"
	"sync"

	"umiuni2d_backend/article"
	"umiuni2d_backend/blob"
	"umiuni2d_backend/session"
	"umiuni2d_backend/tag"
	"umiuni2d_backend/user"

	"golang.org/x/net/context"

	//	"io"

	"crypto/rand"
	"encoding/binary"
	"strconv"

	"google.golang.org/appengine/log"
)

const (
	ReqPropertyName               = "userName"
	ReqPropertyFileName           = "fileName"
	ReqPropertyBlobKey            = "blobKey"
	ReqPropertyPass               = "password"
	ReqPropertyNewPass            = "newpassword"
	ReqPropertyRequestID          = "requestId"
	ReqPropertyCode               = "code"
	ReqPropertyCursor             = "cursor"
	ReqPropertyCursorNext         = "cursor_next"
	ReqPropertyArticles           = "arts"
	ReqPropertyMail               = "mail"
	ReqPropertyUrl                = "url"
	ReqPropertyLoginId            = "loginId"
	ReqPropertyArticleCont        = "cont"
	ReqPropertyArticleTitle       = "title"
	ReqPropertyArticleTag         = "tag"
	ReqPropertyArticleInfo        = "info"
	ReqPropertyArticleId          = "articleId"
	ReqPropertyArticleState       = "state"
	ReqPropertyStateWrongNamePass = "wrong name/pass"
	ReqPropertyUpdated            = "updated"
	ReqPropertyCreated            = "created"

	ReqPropertyStateWrongNamePassID = -1
	ReqPropertyCodeOK               = 200
	ReqPropertyCodeError            = 2000
	ReqPropertyCodeAlreadyExist     = 1000
	ReqPropertyCodeNotFound         = 1001
	ReqPropertyCodeWrongNamePass    = 1002
	ReqPropertyCodeWrongID          = 1003
)

const (
	KindUser       = "MyAppUser"
	KindLoginId    = "MyLoginId"
	KindArticle    = "Article"
	KindArticleTag = "ArticleTag"
	KindBlob       = "BlobItem"
)

var apiKey string = "A91A3E1B-15F0-4DEE-8ECE-F5DD1A06230E"
var _manager = user.NewUserManager(KindUser, KindLoginId)
var _artMana = article.NewArticleManager(KindArticle, 10)
var _tagMan = tag.NewTagManager(KindArticleTag)
var _blobMana = blob.NewBlobManager("/api/v1/file/on_uploaded", KindBlob)

func GetUserManager() *user.UserManager {
	return _manager
}

func GetArtManager() *article.ArticleManager {
	return _artMana
}

func GetTagManager() *tag.TagManager {
	return _tagMan
}

func GetBlobManager() *blob.BlobManager {
	return _blobMana
}

func WriteLog(ctx context.Context, message string) {
	log.Infof(ctx, "%s", message)
}

func Response(w http.ResponseWriter, v map[string]interface{}) {
	b, _ := json.Marshal(v)
	fmt.Fprintln(w, string(b))
}

func init() {

	//
	// me_mana
	http.HandleFunc("/api/v1/me_mana/regist_user", registHandler)
	http.HandleFunc("/api/v1/me_mana/login", loginHandler)
	http.HandleFunc("/api/v1/me_mana/get_icon", userGetIconHandle)
	http.HandleFunc("/api/v1/me_mana/get_info", meCheckHandler)
	http.HandleFunc("/api/v1/me_mana/update_mail", meUpdateMailHandler)
	http.HandleFunc("/api/v1/me_mana/update_password", meUpdatePasswordHandler)
	http.HandleFunc("/api/v1/me_mana/logout", logoutHandler)

	//
	// art_mana
	http.HandleFunc("/api/v1/art_mana/post", articlePostHandler)
	http.HandleFunc("/api/v1/art_mana/find_with_neworder", articleFindWithNewOrderHandler)
	http.HandleFunc("/api/v1/art_mana/get", articleGetHandler)
	http.HandleFunc("/api/v1/art_mana/find_from_username", articlefindFromUserNameHandler)

	//
	// fileshare
	http.HandleFunc("/api/v1/file/get_request_id", fileGetRequestIdHandler)
	http.HandleFunc("/api/v1/file/on_uploaded", fileOnUploadedHandler)

	http.HandleFunc("/api/v1/file/delete", fileDeleteHandler)
	http.HandleFunc("/api/v1/file/get", fileGetHandle)
	http.HandleFunc("/api/v1/file/find_from_article", fileFindFromArticleHandler)

	// me

	// article

	http.HandleFunc("/api/v1/article/vote", articleVoteHandler)
	http.HandleFunc("/api/v1/article/post_comment", articlePostCommentHandler)
	http.HandleFunc("/api/v1/article/get_comments", articleGetCommentsHandler)

	http.HandleFunc("/api/v1/article/find_from_tag", articleFindFromTagHandler)

	http.HandleFunc("/api/v1/me/rescue_from_mail", meRescueFromMailHandler)

}

func apiHandler(w http.ResponseWriter, r *http.Request) {
	var once sync.Once

	if r.Method == "GET" {
		w.Header().Add("Access-Control-Allow-Origin", "*")
		w.Header().Add("Access-Control-Allow-Headers", "apikey")
		fmt.Fprintln(w, "GET")
	} else {
		once.Do(func() {
			registHandler(w, r)
		})
	}
}

func makeRandomId() string {
	var n uint64
	binary.Read(rand.Reader, binary.LittleEndian, &n)
	return strconv.FormatUint(n, 36)
}

func loginCheckHandler(ctx context.Context, r *http.Request, data map[string]interface{}) (bool, *session.AccessToken, error) {
	loginHash := data[ReqPropertyLoginId].(string)
	return GetUserManager().CheckLoginId(ctx, loginHash, r.RemoteAddr, r.UserAgent())
}
