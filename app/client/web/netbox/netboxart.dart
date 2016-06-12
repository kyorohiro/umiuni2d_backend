import 'dart:async';
import './requester.dart';
import 'dart:convert' as conv;
import 'dart:html' as html;
import 'netbox.dart';

class NetBoxArtManagerPost {
  int code;
  String requestId;
  String loginId;
  String articleId;
  String articleState;

  NetBoxArtManagerPost(TinyNetRequesterResponse response) {
    String body = conv.UTF8.decode(response.response.asUint8List());
    Map<String, Object> ret = conv.JSON.decode(body);
    this.code = ret[NetBox.ReqPropertyCode];
    this.requestId = ret[NetBox.ReqPropertyRequestID];
    this.loginId = ret[NetBox.ReqPropertyLoginId];
    this.articleState = ret[NetBox.ReqPropertyArticleState];
    this.articleId = ret[NetBox.ReqPropertyArticleId];
  }
}

class NetBoxArtManagerFindArt {
  String articleId;
  String userName;
  String title;
  String state;
  String tag;
  int updated;
  int created;
}

class NetBoxArtManagerFind {
  int code;
  String requestId;
  String loginId;
  String cursorNext;
  List<NetBoxArtManagerFindArt> arts = [];

  NetBoxArtManagerFind(TinyNetRequesterResponse response) {
    String body = conv.UTF8.decode(response.response.asUint8List());
    Map<String, Object> ret = conv.JSON.decode(body);
    this.code = ret[NetBox.ReqPropertyCode];
    this.requestId = ret[NetBox.ReqPropertyRequestID];
    this.loginId = ret[NetBox.ReqPropertyLoginId];
    this.cursorNext = ret[NetBox.ReqPropertyCursorNext];
    this.arts = load(ret);
  }

  List<NetBoxArtManagerFindArt>load(Map<String, Object> src) {
    List ret = [];
    Object o = src["ReqPropertyArticles"];
    if(o == null || !(o is List)) {
      return ret;
    }
    for(var v in o) {
        if(v == null || !(v is Map)) {
          continue;
        }
        //
        NetBoxArtManagerFindArt a = new NetBoxArtManagerFindArt();
        a.articleId = v[NetBox.ReqPropertyArticleId];
        a.userName = v[NetBox.ReqPropertyName];
        a.title = v[NetBox.ReqPropertyTitle];
        a.state = v[NetBox.ReqPropertyArticleState];
        a.tag = v[NetBox.ReqPropertyTag];
        a.created = v[NetBox.ReqPropertyCreated];
        a.updated = v[NetBox.ReqPropertyUpdated];
        ret.add(a);
    }
    return ret;
  }
}

class NetBoxArtManager {
  String backendAddr;
  String apiKey;
  String version;
  String passwordKey;

  NetBoxArtManager(this.backendAddr, this.apiKey, {this.version: "v1", this.passwordKey: "umiuni2d"}) {}

  Future<NetBoxArtManagerPost> post(String userName, String loginId, String articleId, String title, String tag, String cont, String state) async {
    TinyNetHtml5Builder builder = new TinyNetHtml5Builder();
    TinyNetRequester requester = await builder.createRequester();
    String url = "${this.backendAddr}/api/${version}/art_mana/post";

    TinyNetRequesterResponse response = await requester.request(TinyNetRequester.TYPE_POST, url, //
        data: conv.JSON.encode({
          NetBox.ReqPropertyTag: tag, //
          NetBox.ReqPropertyTitle: title, //
          NetBox.ReqPropertyCont: cont, //
          NetBox.ReqPropertyArticleState: state, //
          NetBox.ReqPropertyName: userName, //
          NetBox.ReqPropertyArticleId: articleId, //
          NetBox.ReqPropertyLoginId: loginId, //
          NetBox.ReqPropertyRequestID: "AABBCC", //
          NetBox.ReqPropertyApiKey: apiKey
        }));
    //print(">> ${conv.UTF8.decode(response.response.asUint8List())}");
    return new NetBoxArtManagerPost(response);
  }

  Future<NetBoxArtManagerFind> findArticleWithNewOrde(String cursor) async {
    print("--");
    TinyNetHtml5Builder builder = new TinyNetHtml5Builder();
    TinyNetRequester requester = await builder.createRequester();
    String url = "${this.backendAddr}/api/${version}/art_mana/find_with_neworder";
    TinyNetRequesterResponse response = await requester.request(TinyNetRequester.TYPE_POST, url, //
        data: conv.JSON.encode({
//          NetBox.ReqPropertyLoginId: loginId, //
          NetBox.ReqPropertyRequestID: "AABBCC", //
          NetBox.ReqPropertyApiKey: apiKey,
          NetBox.ReqPropertyCursor: cursor
        }));
    return new NetBoxArtManagerFind(response);
  }
}
