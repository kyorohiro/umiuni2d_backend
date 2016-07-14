package twitter

//
// https://dev.twitter.com/oauth/overview
// https://dev.twitter.com/web/sign-in/implementing
//
import (
	"errors"
	"net/url"
	"strings"

	"golang.org/x/net/context"
	"google.golang.org/appengine/log"
)

type Twitter struct {
	ConsumerKey       string
	ConsumerSecret    string
	AccessToken       string
	AccessTokenSecret string
	CallbackUrl       string
	oauthObj          *OAuth1Client
}

const (
	RequestTokenURl        = "https://api.twitter.com/oauth/request_token"
	AccessTokenURL         = "https://api.twitter.com/oauth/access_token"
	OAuthToken             = "oauth_token"
	OAuthTokenSecret       = "oauth_token_secret"
	OAuthCallbackConfirmed = "oauth_callback_confirmed"
	OAuthVerifier          = "oauth_verifier"
	UserID                 = "user_id"
	ScreenName             = "screen_name"
)

func NewTwitter(consumerKey string, consumerSecret string, accessToken string, accessTokenSecret string, callbackUrl string) *Twitter {
	ret := new(Twitter)
	ret.ConsumerKey = consumerKey
	ret.ConsumerSecret = consumerSecret
	ret.AccessToken = accessToken
	ret.AccessTokenSecret = accessTokenSecret
	ret.CallbackUrl = callbackUrl
	ret.oauthObj = NewOAuthClient(consumerKey, consumerSecret, accessToken, accessTokenSecret)

	return ret
}

//
// OAuthToken
// OAuthTokenSecret
// OAuthCallbackConfirmed
func (obj *Twitter) SendRequestToken(ctx context.Context) (string, map[string]string, error) {
	obj.oauthObj.Callback = obj.CallbackUrl
	log.Infof(ctx, obj.CallbackUrl)
	result, err := obj.oauthObj.Post(ctx, RequestTokenURl, make(map[string]string, 0), "")
	obj.oauthObj.Callback = ""
	if err != nil {
		return "", nil, err
	}
	log.Infof(ctx, "<<%s>>", result)
	keyvalue := obj.ExtractParamsFromBody(result)
	oauth_token := keyvalue[OAuthToken]
	if oauth_token == "" {
		return "", nil, err
	}

	return "https://api.twitter.com/oauth/authenticate?oauth_token=" + oauth_token, keyvalue, nil
}

//
// OAuthToken
// OAuthTokenSecret
// UserID
// ScreenName
func (obj *Twitter) OnCallbackSendRequestToken(ctx context.Context, url *url.URL) (map[string]string, map[string]string, error) {
	log.Infof(ctx, "<<ONCALL>>")
	q := url.Query()
	verifiers := q[OAuthVerifier]
	tokens := q[OAuthToken]

	if len(verifiers) != 1 || len(tokens) != 1 {
		return nil, nil, errors.New("unexpected query")
	}
	ret1 := make(map[string]string, 0)
	ret1[OAuthVerifier] = verifiers[0]
	ret1[OAuthToken] = tokens[0]
	ret2, ret3 := obj.SendAccessToken(ctx, tokens[0], verifiers[0])
	return ret1, ret2, ret3
}

//
// OAuthToken
// OAuthTokenSecret
// UserID
// ScreenName
func (obj *Twitter) SendAccessToken(ctx context.Context, oauthToken string, oauthVerifier string) (map[string]string, error) {
	obj.oauthObj.Callback = ""
	obj.oauthObj.AccessToken = oauthToken
	result, err := obj.oauthObj.Post(ctx, AccessTokenURL, //
		map[string]string{"Content-Type": "application/x-www-form-urlencoded"},
		"oauth_verifier="+oauthVerifier+"\r\n")
	if err != nil {
		return nil, err
	}
	keyvalue := obj.ExtractParamsFromBody(result)
	log.Infof(ctx, "----------->>-> %s", keyvalue)
	return keyvalue, nil
}

func (obj *Twitter) ExtractParamsFromBody(body string) map[string]string {
	ret := make(map[string]string, 0)
	keyvalues := strings.Split(body, "&")
	for _, v := range keyvalues {
		kv := strings.Split(v, "=")
		if len(kv) == 2 {
			ret[kv[0]] = kv[1]
		}
	}
	return ret
}
