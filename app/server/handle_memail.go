package hello

import (
	"encoding/json"
	"fmt"
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
	// find user
	ctx := appengine.NewContext(r)
	isLogin, accessTokenObj, _ := loginCheckHandler(ctx, r)
	if isLogin == false {
		m := map[string]string{"ret": "ng", "stat": "not found1", "reqId": reqId}
		b, _ := json.Marshal(m)
		fmt.Fprintln(w, string(b))
		return
	}

	userObj, err1 := GetUserManager().FindUserFromUserName(ctx, accessTokenObj.GetUserName())
	if err1 != nil {
		m := map[string]string{"ret": "ng", "stat": "not found2", "reqId": reqId}
		b, _ := json.Marshal(m)
		fmt.Fprintln(w, string(b))
		return
	}
	userObj.CheckPassword(pass)
	if userObj.CheckPassword(pass) == false {
		m := map[string]string{"ret": "ng", "stat": "not found3", "reqId": reqId}
		b, _ := json.Marshal(m)
		fmt.Fprintln(w, string(b))
		return
	}
	userObj.SetMail(email)
	err := userObj.PushToDB(ctx)
	if err != nil {
		m := map[string]string{"ret": "ng", "stat": "error", "reqId": reqId}
		b, _ := json.Marshal(m)
		fmt.Fprintln(w, string(b))
	} else {
		m := map[string]string{"ret": "ok", "stat": "good", "reqId": reqId}
		b, _ := json.Marshal(m)
		fmt.Fprintln(w, string(b))
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
	isLogin, accessTokenObj, _ := loginCheckHandler(ctx, r)
	if isLogin == false {
		m := map[string]string{"ret": "ng", "stat": "not found1", "reqId": reqId}
		b, _ := json.Marshal(m)
		fmt.Fprintln(w, string(b))
		return
	}

	userObj, err1 := GetUserManager().FindUserFromUserName(ctx, accessTokenObj.GetUserName())
	if err1 != nil {
		m := map[string]string{"ret": "ng", "stat": "not found2", "reqId": reqId}
		b, _ := json.Marshal(m)
		fmt.Fprintln(w, string(b))
		return
	}
	if userObj.CheckPassword(pass) == false {
		m := map[string]string{"ret": "ng", "stat": "not found3", "reqId": reqId}
		b, _ := json.Marshal(m)
		fmt.Fprintln(w, string(b))
		return
	}

	userObj.UpdatePassword(newpass)
	err2 := userObj.PushToDB(ctx)

	if err2 != nil {
		m := map[string]string{"ret": "ng", "stat": "error", "reqId": reqId}
		b, _ := json.Marshal(m)
		fmt.Fprintln(w, string(b))
		return
	}

	m := map[string]string{
		"ret":   "ok",
		"stat":  "good",
		"reqId": reqId,
	}
	b, _ := json.Marshal(m)
	fmt.Fprintln(w, string(b))

}
