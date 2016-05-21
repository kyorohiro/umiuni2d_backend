// gaeuser project gaeuser.go
package gaeuser

import (
	"golang.org/x/net/context"
	"google.golang.org/appengine/datastore"
)

//
//
func (obj *UserManager) NewUser(ctx context.Context, userName string) *User {
	ret := new(User)
	ret.kind = obj.userKind
	ret.gaeObject = new(GaeUserItem)
	ret.gaeObject.UserName = userName
	ret.gaeObjectKey = obj.NewUserGaeObjectKey(ctx, userName)
	return ret
}

//
// need load or make
func (obj *UserManager) NewUserFromsGaeObject(key *datastore.Key, item *GaeUserItem) *User {
	ret := new(User)
	ret.gaeObject = item
	ret.gaeObjectKey = key
	ret.kind = obj.userKind
	return ret
}

func (obj *UserManager) MakeUserGaeObjectKeyStringId(userName string) string {
	return obj.userKind + ":" + userName
}

func (obj *UserManager) NewUserGaeObjectKey(ctx context.Context, userName string) *datastore.Key {
	return datastore.NewKey(ctx, obj.userKind, obj.MakeUserGaeObjectKeyStringId(userName), 0, nil)
}
