package hello

import (
	"encoding/json"
	"net/http"

	"umiuni2d_backend/user"

	"google.golang.org/appengine"
)

// ------
// Regist Handler
// ------
func registHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")
	if r.Method != "POST" {
		return
	}
	var requestPropery map[string]interface{}
	json.NewDecoder(r.Body).Decode(&requestPropery)
	propUserName := requestPropery[ReqPropertyName].(string)
	propPassword := requestPropery[ReqPropertyPass].(string)
	propRequestId := requestPropery[ReqPropertyRequestID].(string)
	propMail := requestPropery[ReqPropertyMail].(string)
	//
	ctx := appengine.NewContext(r)
	_, err1 := GetUserManager().RegistUser(ctx, propUserName, propPassword, propMail)

	if err1 != nil {
		m := map[string]interface{}{"ret": "ng", "stat": "error", "reqId": propRequestId, "dev": err1.Error()}
		Response(w, m)
		return
	}

	loginId, _, _ := GetUserManager().LoginUser(ctx, propUserName, propPassword, r.RemoteAddr, r.UserAgent())

	m := map[string]interface{}{"ret": "ok", "stat": "good", "reqId": propRequestId, "loginId": loginId.GetLoginId()}
	Response(w, m)

}

// ------
// Regist Handler
// ------
func loginHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")
	if r.Method != "POST" {
		return
	}
	var requestPropery map[string]interface{}
	json.NewDecoder(r.Body).Decode(&requestPropery)
	propUserName := requestPropery[ReqPropertyName].(string)
	propPassword := requestPropery[ReqPropertyPass].(string)
	propRequestId := requestPropery[ReqPropertyRequestID].(string)
	//
	ctx := appengine.NewContext(r)
	loginId, _, err1 := GetUserManager().LoginUser(ctx, propUserName, propPassword, r.RemoteAddr, r.UserAgent())

	if err1 != nil {
		state := err1.Error()
		if err1 == user.ErrorNotFound || err1 == user.ErrorInvalidPass {
			state = ReqPropertyStateWrongNamePass
		}
		m := map[string]interface{}{"ret": "ng", "stat": state, "reqId": propRequestId, "dev": err1.Error()}
		Response(w, m)
		return
	} else {
		m := map[string]interface{}{"ret": "ok", "stat": "good", "reqId": propRequestId, "loginId": loginId.GetLoginId()}
		Response(w, m)
	}
}

func logoutHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")
	if r.Method != "POST" {
		return
	}
	var requestPropery map[string]interface{}
	json.NewDecoder(r.Body).Decode(&requestPropery)
	propRequestId := requestPropery[ReqPropertyRequestID].(string)
	propLoginId := requestPropery[ReqPropertyLoginId].(string)
	//
	ctx := appengine.NewContext(r)
	err1 := GetUserManager().LogoutUser(ctx, propLoginId, r.RemoteAddr, r.UserAgent())

	if err1 != nil {
		m := map[string]interface{}{"ret": "ng", "stat": "error", "reqId": propRequestId, "dev": err1.Error()}
		Response(w, m)
		return
	} else {
		m := map[string]interface{}{"ret": "ok", "stat": "good", "reqId": propRequestId}
		Response(w, m)
	}
}

func meCheckHandler(w http.ResponseWriter, r *http.Request) {
	ctx := appengine.NewContext(r)
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")

	//
	//
	if r.Method != "POST" {
		// you must to consider HEAD
		return
	}

	//
	// parse
	var data map[string]interface{}
	json.NewDecoder(r.Body).Decode(&data)
	reqId := data[ReqPropertyRequestID].(string)

	isLogin, accessTokenObj, _ := loginCheckHandler(ctx, r)
	if isLogin == false {
		Response(w, map[string]interface{}{"ret": "ng", "stat": "not found", "reqId": reqId})
		return
	}

	userObj, err2 := GetUserManager().FindUserFromUserName(ctx, accessTokenObj.GetUserName())
	if isLogin == false || err2 != nil {
		Response(w, map[string]interface{}{"ret": "ng", "stat": "not found", "reqId": reqId})
		return
	} else {
		m := map[string]interface{}{
			"ret":   "ok",
			"stat":  "good",
			"reqId": reqId,
			"name":  userObj.GetUserName(),
			"mail":  userObj.GetMail(),
		}
		Response(w, m)
		return
	}

}
