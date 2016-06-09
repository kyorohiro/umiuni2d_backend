package hello

import (
	"encoding/json"
	//	"fmt"
	"net/http"

	"google.golang.org/appengine"
)

// ------
// Rescue From Mail Handler
// ------
func meRescueFromMailHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")
	//	var v string = r.Method
	if r.Method != "POST" {
		// you must to consider HEAD
		return
	}

	// make
	// parse
	var data map[string]interface{}
	json.NewDecoder(r.Body).Decode(&data)
	mail := data[ReqPropertyMail].(string)
	reqId := data[ReqPropertyRequestID].(string)

	ctx := appengine.NewContext(r)
	userObj, err1 := GetUserManager().FindUserFromMail(ctx, mail)
	if err1 != nil {
		m := map[string]interface{}{"ret": "ng", "stat": "not found mail", "reqId": reqId}
		Response(w, m)
		return
	}
	//
	//
	newPassword := makeRandomId()
	userObj.UpdatePassword(newPassword)

	err3 := SendMail(ctx, "Reset Password", "newpassword \r\n----\r\n"+newPassword+"\r\n----\r\n", []string{mail})
	if err3 != nil {
		m := map[string]interface{}{"ret": "ng", "stat": "failed to send mail", "reqId": reqId, "dev": err3.Error()}
		Response(w, m)
		return
	}

	err2 := userObj.PushToDB(ctx)
	if err2 != nil {
		m := map[string]interface{}{"ret": "ng", "stat": "failed to update password", "reqId": reqId}
		Response(w, m)
		return
	}

	//
	//
	m := map[string]interface{}{
		"ret":   "ok",
		"stat":  "good",
		"reqId": reqId,
	}
	Response(w, m)
}

// ------
// Me Handler
// ------
func meUpdateMailHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")
	//	var v string = r.Method
	if r.Method != "POST" {
		// you must to consider HEAD
		return
	}

	// make
	// parse
	var data map[string]interface{}
	json.NewDecoder(r.Body).Decode(&data)
	reqId := data[ReqPropertyRequestID].(string)
	pass := data[ReqPropertyPass].(string)
	email := data[ReqPropertyMail].(string)
	//
	// find user
	ctx := appengine.NewContext(r)
	isLogin, accessTokenObj, _ := loginCheckHandler(ctx, r, data)
	if isLogin == false {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeNotFound, ReqPropertyRequestID: reqId})
		return
	}

	userObj, err1 := GetUserManager().FindUserFromUserName(ctx, accessTokenObj.GetUserName())
	if err1 != nil {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeNotFound, ReqPropertyRequestID: reqId})
		return
	}
	userObj.CheckPassword(pass)
	if userObj.CheckPassword(pass) == false {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeWrongNamePass, ReqPropertyRequestID: reqId})
		return
	}
	userObj.SetMail(email)
	err := userObj.PushToDB(ctx)
	if err != nil {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeError, ReqPropertyRequestID: reqId})
		return
	} else {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeOK, ReqPropertyRequestID: reqId})
		return
	}
}

// ------
// Me Handler
// ------
func meUpdatePasswordHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Headers", "apikey")
	//	var v string = r.Method
	if r.Method != "POST" {
		// you must to consider HEAD
		return
	}

	// make
	// parse
	var data map[string]interface{}
	json.NewDecoder(r.Body).Decode(&data)
	reqId := data[ReqPropertyRequestID].(string)
	pass := data[ReqPropertyPass].(string)
	newpass := data[ReqPropertyNewPass].(string)

	// find user
	ctx := appengine.NewContext(r)
	isLogin, accessTokenObj, _ := loginCheckHandler(ctx, r, data)
	if isLogin == false {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeNotFound, ReqPropertyRequestID: reqId})
		return
	}

	userObj, err1 := GetUserManager().FindUserFromUserName(ctx, accessTokenObj.GetUserName())
	if err1 != nil {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeNotFound, ReqPropertyRequestID: reqId})
		return
	}
	if userObj.CheckPassword(pass) == false {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeWrongNamePass, ReqPropertyRequestID: reqId})
		return
	}

	userObj.UpdatePassword(newpass)
	err2 := userObj.PushToDB(ctx)

	if err2 != nil {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeError, ReqPropertyRequestID: reqId})
		return
	}

	Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeOK, ReqPropertyRequestID: reqId})
}
