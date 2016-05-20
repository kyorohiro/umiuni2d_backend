package twitter

//
// https://dev.twitter.com/oauth/overview
// https://dev.twitter.com/web/sign-in/implementing
//
import (
	"strings"

	"golang.org/x/net/context"
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

func (obj *Twitter) RequestToken(ctx context.Context) (string, error) {
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
