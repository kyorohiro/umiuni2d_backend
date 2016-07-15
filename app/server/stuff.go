package hello

import (
	"encoding/json"
	"net/http"

	"google.golang.org/appengine"
)

func stuffloginHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	//	w.Header().Add("Access-Control-Allow-Headers", "apikey")
	if r.Method != "POST" {
		return
	}
	var requestPropery map[string]interface{}
	json.NewDecoder(r.Body).Decode(&requestPropery)
	propUserName := requestPropery[ReqPropertyName].(string)
	propPassword := requestPropery[ReqPropertyPass].(string)
	propRequestId := requestPropery[ReqPropertyRequestID].(string)

	//
	//
	ctx := appengine.NewContext(r)
	loginId, user, err1 := GetUserManager().LoginUser(ctx, propUserName, propPassword, r.RemoteAddr, r.UserAgent())
	if err1 != nil || user.GetUserName() != ConfigMasterUser {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeWrongNamePass, ReqPropertyRequestID: propRequestId})
	} else {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeOK, ReqPropertyRequestID: propRequestId, ReqPropertyLoginId: loginId.GetLoginId()})
	}
}
