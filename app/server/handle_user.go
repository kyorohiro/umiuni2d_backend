package hello

import (
	"encoding/json"
	"net/http"

	"umiuni2d_backend/user"

	"google.golang.org/appengine"
	"google.golang.org/appengine/blobstore"
)

// ------
// Regist Handler
// ------
func registHandler(w http.ResponseWriter, r *http.Request) {
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
	propMail := requestPropery[ReqPropertyMail].(string)
	//
	ctx := appengine.NewContext(r)
	_, err1 := GetUserManager().RegistUser(ctx, propUserName, propPassword, propMail)

	if err1 != nil {
		Response(w, map[string]interface{}{ //
			ReqPropertyCode:      ReqPropertyCodeAlreadyExist, //
			ReqPropertyRequestID: propRequestId})
		return
	}

	loginId, _, _ := GetUserManager().LoginUser(ctx, propUserName, propPassword, r.RemoteAddr, r.UserAgent())

	Response(w, map[string]interface{}{ //
		ReqPropertyCode:      ReqPropertyCodeOK,
		ReqPropertyRequestID: propRequestId, //
		ReqPropertyLoginId:   loginId.GetLoginId()})

}

// ------
// Regist Handler
// ------
func loginHandler(w http.ResponseWriter, r *http.Request) {
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
	ctx := appengine.NewContext(r)
	loginId, _, err1 := GetUserManager().LoginUser(ctx, propUserName, propPassword, r.RemoteAddr, r.UserAgent())

	if err1 != nil {
		//		state := err1.Error()
		//		if err1 == user.ErrorNotFound || err1 == user.ErrorInvalidPass {
		//			state = ReqPropertyStateWrongNamePass
		//		}
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeWrongNamePass, ReqPropertyRequestID: propRequestId})
	} else {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeOK, ReqPropertyRequestID: propRequestId, ReqPropertyLoginId: loginId.GetLoginId()})
	}
}

func logoutHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	//	w.Header().Add("Access-Control-Allow-Headers", "apikey")
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
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeNotFound, ReqPropertyRequestID: propRequestId})
		return
	} else {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeOK, ReqPropertyRequestID: propRequestId})
	}
}

func meCheckHandler(w http.ResponseWriter, r *http.Request) {
	ctx := appengine.NewContext(r)
	w.Header().Add("Access-Control-Allow-Origin", "*")

	//
	//
	if r.Method != "POST" {
		return
	}
	var requestPropery map[string]interface{}
	json.NewDecoder(r.Body).Decode(&requestPropery)
	propRequestId := requestPropery[ReqPropertyRequestID].(string)

	isLogin, accessTokenObj, _ := loginCheckHandler(ctx, r, requestPropery)
	if isLogin == false {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeNotFound, ReqPropertyRequestID: propRequestId})
		return
	}

	userObj, err2 := GetUserManager().FindUserFromUserName(ctx, accessTokenObj.GetUserName())
	if isLogin == false || err2 != nil {
		Response(w, map[string]interface{}{ReqPropertyCode: ReqPropertyCodeNotFound, ReqPropertyRequestID: propRequestId})
		return
	} else {
		isMasterManager := false
		if userObj.GetUserName() == ConfigMasterUser {
			isMasterManager = true
		}
		Response(w, map[string]interface{}{
			ReqPropertyCode:      ReqPropertyCodeOK,
			ReqPropertyRequestID: propRequestId,
			ReqPropertyName:      userObj.GetUserName(),
			ReqPropertyMail:      userObj.GetMail(),
			ReqPropertyIsMaster:  isMasterManager,
		})
		return
	}

}

//
func userGetIconHandle(w http.ResponseWriter, r *http.Request) {
	name := r.FormValue("name")
	ctx := appengine.NewContext(r)

	b, e := GetBlobManager().GetBlobItem(ctx, "/user/"+name, "meicon")
	if e != nil {
		http.Redirect(w, r, "/images/meicon.gif", http.StatusFound)
		return
	}
	blobstore.Send(w, appengine.BlobKey(b.GetBlobKey()))
}

//
//
func userFindWithNewOrderHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	//w.Header().Add("Access-Control-Allow-Headers", "apikey")

	if r.Method != "POST" {
		// you must to consider HEAD
		return
	}

	var requestPropery map[string]interface{}
	json.NewDecoder(r.Body).Decode(&requestPropery)
	propCursorSrc := getStringFromProp(requestPropery, ReqPropertyCursor, "")

	ctx := appengine.NewContext(r)
	u, cN, cO := GetUserManager().FindUserWithNewOrder(ctx, propCursorSrc)
	findUserResponse(w, requestPropery, u, cN, cO)
}

//
//
func findUserResponse(w http.ResponseWriter, requestPropery map[string]interface{}, u []*user.User, cursorOne string, cursorNext string) {
	var userList []interface{}
	for _, v := range u {

		w := map[string]interface{}{
			ReqPropertyName: v.GetUserName(),
			//ReqPropertyUpdated: v.GetUpdated().UnixNano() / 1000,
			//ReqPropertyCreated: v.GetCreated().UnixNano() / 1000
		}

		userList = append(userList, w)
	}

	//
	// ok
	m := map[string]interface{}{
		ReqPropertyCode:       ReqPropertyCodeOK,
		ReqPropertyRequestID:  requestPropery[ReqPropertyRequestID].(string),
		ReqPropertyUsers:      userList,
		ReqPropertyCursorNext: cursorNext,
	}
	Response(w, m)
}
