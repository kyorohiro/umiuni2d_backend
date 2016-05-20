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
	RequestTokenURl = "https://api.twitter.com/oauth/request_token"
	AccessTokenURL  = "https://api.twitter.com/oauth/access_token"
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

func (obj *Twitter) SendRequestToken(ctx context.Context) (string, error) {
	result, err := obj.oauthObj.Post(ctx, RequestTokenURl, make(map[string]string, 0), "")
	if err != nil {
		return "", err
	}
	keyvalues := strings.Split(result, "&")
	oauth_token := ""
	//oauth_token_secret := ""
	for _, v := range keyvalues {
		kv := strings.Split(v, "=")
		if len(kv) == 2 {
			if kv[0] == "oauth_token" {
				oauth_token = kv[1]
			}
			//if kv[0] == "oauth_token_secret" {
			//	oauth_token_secret = kv[1]
			//}
		}
	}
	if oauth_token == "" {
		return "", err
	}
	return "https://api.twitter.com/oauth/authenticate?oauth_token=" + oauth_token, nil
}

func (obj *Twitter) OnOAuthCallback(ctx context.Context, url *url.URL) (string, error) {
	q := url.Query()
	verifiers := q["oauth_verifier"]
	tokens := q["oauth_token"]

	if len(verifiers) != 1 || len(tokens) != 1 {
		return "", errors.New("unexpected query")
	}

	return obj.SendAccessToken(ctx, tokens[0], verifiers[0])
}

func (obj *Twitter) SendAccessToken(ctx context.Context, oauthToken string, oauthVerifier string) (string, error) {
	obj.oauthObj.Callback = ""
	obj.oauthObj.AccessToken = oauthToken
	result, err := obj.oauthObj.Post(ctx, AccessTokenURL, //
		map[string]string{"Content-Type": "application/x-www-form-urlencoded"},
		"oauth_verifier="+oauthVerifier+"\r\n")
	if err != nil {
		return "", err
	}
	log.Infof(ctx, "----------->>-> %s", result)
	return "", nil
}
