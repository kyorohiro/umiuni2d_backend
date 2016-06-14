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
  String articleInfo;
  String articleId;
  String userName;
  String title;
  String state;
  String cont;
  String tag;
  int updated;
  int created;
  NetBoxArtManagerFindArt.empty() {}
  NetBoxArtManagerFindArt(TinyNetRequesterResponse response) {
    String body = conv.UTF8.decode(response.response.asUint8List());
    Map<String, Object> v = conv.JSON.decode(body);
    this.articleId = v[NetBox.ReqPropertyArticleId];
    this.userName = v[NetBox.ReqPropertyName];
    this.title = v[NetBox.ReqPropertyTitle];
    this.state = v[NetBox.ReqPropertyArticleState];
    this.tag = v[NetBox.ReqPropertyTag];
    this.created = v[NetBox.ReqPropertyCreated];
    this.updated = v[NetBox.ReqPropertyUpdated];
    this.articleInfo = v[NetBox.ReqPropertyArticleInfo];
    this.cont = v[NetBox.ReqPropertyCont];
  }
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

  List<NetBoxArtManagerFindArt> load(Map<String, Object> src) {
    List ret = [];
    Object o = src[NetBox.ReqPropertyArticles];
    if (o == null || !(o is List)) {
      print("----> (1) ${o}");
      return ret;
    }
    for (var v in (o as List)) {
      print("----> (2)");

      if (v == null || !(v is Map)) {
        continue;
      }
      //
      NetBoxArtManagerFindArt a = new NetBoxArtManagerFindArt.empty();
      a.articleId = v[NetBox.ReqPropertyArticleId];
      a.userName = v[NetBox.ReqPropertyName];
      a.title = v[NetBox.ReqPropertyTitle];
      a.state = v[NetBox.ReqPropertyArticleState];
      a.tag = v[NetBox.ReqPropertyTag];
      a.created = v[NetBox.ReqPropertyCreated];
      a.updated = v[NetBox.ReqPropertyUpdated];
      a.articleInfo = v[NetBox.ReqPropertyArticleInfo];
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

  Future<NetBoxArtManagerFind> findArticleWithUserName(String userName, String cursor) async {
    TinyNetHtml5Builder builder = new TinyNetHtml5Builder();
    TinyNetRequester requester = await builder.createRequester();
    String url = "${this.backendAddr}/api/${version}/art_mana/find_with_neworder";
    TinyNetRequesterResponse response = await requester.request(TinyNetRequester.TYPE_POST, url, //
        data: conv.JSON.encode({
//          NetBox.ReqPropertyLoginId: loginId, //
          NetBox.ReqPropertyName: userName, //
          NetBox.ReqPropertyRequestID: "AABBCC", //
          NetBox.ReqPropertyApiKey: apiKey,
          NetBox.ReqPropertyCursor: cursor
        }));
    return new NetBoxArtManagerFind(response);
  }

  Future<NetBoxArtManagerFindArt> getArticleFromArticleId(String articleId) async {
    TinyNetHtml5Builder builder = new TinyNetHtml5Builder();
    TinyNetRequester requester = await builder.createRequester();
    String url = "${this.backendAddr}/api/${version}/art_mana/get";

    TinyNetRequesterResponse response = await requester.request(
        TinyNetRequester.TYPE_POST, //
        url,
        data: conv.JSON.encode({
          NetBox.ReqPropertyRequestID: "AABBCC", //
          NetBox.ReqPropertyApiKey: apiKey, //
          NetBox.ReqPropertyArticleId: articleId, //
        }));
    return new NetBoxArtManagerFindArt(response);
  }
}
