import "netboxart.dart" as netbox;
import "netbox.dart" as netbox;
import "requester.dart";
import "dart:async";

typedef Future<netbox.NetBoxArtManagerFind> FuncfindArticle(String cursor);

class NetBoxFeedManager {
  String backendAddr;
  String apiKey;
  String version;
  String passwordKey;
  FuncfindArticle funcfindArticle;

  NetBoxFeed _newOrderBox = null;
  Map<String, NetBoxFeed> _tagBox = {};
  Map<String, NetBoxFeed> _userBox = {};
  TinyNetBuilder builder;
  NetBoxFeedManager(this.builder, this.backendAddr, this.apiKey,
      {this.version: "v1",
      this.passwordKey: "umiuni2d", //
      this.funcfindArticle: null}) {
    _newOrderBox = new NetBoxFeed(this.builder, backendAddr, apiKey, version: this.version, passwordKey: this.passwordKey, funcfindArticle: null);
  }

  NetBoxFeed getNewOrder({String userName: "", String loginId: ""}) {
    if (userName == "") {
      return _newOrderBox;
    } else {
      var r = _userBox[userName];
      if (r != null) {
        return r;
      }
      if (userName == "me") {
        r = new NetBoxFeed.me(this.builder, loginId, backendAddr, apiKey, version: this.version, passwordKey: this.passwordKey);
      } else {
        r = new NetBoxFeed.username(this.builder, userName, backendAddr, apiKey, version: this.version, passwordKey: this.passwordKey);
      }
      _userBox[userName] = r;
      return r;
    }
  }

  NetBoxFeed getFromTag(String tag, String subTag, String optTag) {
    subTag = (subTag == null ? "" : subTag);
    optTag = (optTag == null ? "" : optTag);
    tag = (tag == null ? "" : tag);
    var r = _tagBox[tag + "::" + subTag + "::"];
    if (r != null) {
      return r;
    }
    r = new NetBoxFeed.tag(this.builder, tag, subTag, optTag, backendAddr, apiKey, version: this.version, passwordKey: this.passwordKey);
    _tagBox[tag] = r;
    return r;
  }
}

class NetBoxFeed {
  String headCursor = "";
  String tailCursor = "";

  String backendAddr;
  String apiKey;
  String version;
  String passwordKey;
  FuncfindArticle funcfindArticle;

  List<netbox.NetBoxArtManagerFindArt> founded = [];
  Map<String, netbox.NetBoxArtManagerFindArt> foundedHash = {};
  TinyNetBuilder builder;
  NetBoxFeed(this.builder, this.backendAddr, this.apiKey,
      {this.version: "v1",
      this.passwordKey: "umiuni2d", //
      this.funcfindArticle: null}) {
    if (this.funcfindArticle == null) {
      netbox.NetBoxArtManager art = new netbox.NetBoxArtManager(this.builder, backendAddr, apiKey, version: version, passwordKey: passwordKey);
      this.funcfindArticle = art.findArticleWithNewOrde;
    }
  }

  factory NetBoxFeed.mock(List<netbox.NetBoxArtManagerFindArt> _arts, TinyNetBuilder builder, String loginId, String backendAddr, String apiKey, //
      {String version: "v1",
      String passwordKey: "umiuni2d"}) {
    bool isRelease = false;
    Future<netbox.NetBoxArtManagerFind> adapter(String cursor) async {
      if (isRelease == false) {
        isRelease == true;
        return new netbox.NetBoxArtManagerFind.mock(netbox.NetBox.ReqPropertyCodeOK, "dummy", loginId, cursor, _arts);
      } else {
        return new netbox.NetBoxArtManagerFind.mock(netbox.NetBox.ReqPropertyCodeOK, "dummy", loginId, cursor, []);
      }
    }
    ;
    return new NetBoxFeed(builder, backendAddr, apiKey,
        version: version,
        passwordKey: passwordKey, //
        funcfindArticle: adapter);
  }

  factory NetBoxFeed.me(TinyNetBuilder builder, String loginId, String backendAddr, String apiKey, //
      {String version: "v1",
      String passwordKey: "umiuni2d"}) {
    Future<netbox.NetBoxArtManagerFind> adapter(String cursor) {
      netbox.NetBoxArtManager art = new netbox.NetBoxArtManager(builder, backendAddr, apiKey, version: version, passwordKey: passwordKey);
      return art.findArticleWithMe(loginId, cursor);
    }
    ;
    return new NetBoxFeed(builder, backendAddr, apiKey,
        version: version,
        passwordKey: passwordKey, //
        funcfindArticle: adapter);
  }

  factory NetBoxFeed.username(TinyNetBuilder builder, String userName, String backendAddr, String apiKey, //
      {String version: "v1",
      String passwordKey: "umiuni2d"}) {
    Future<netbox.NetBoxArtManagerFind> adapter(String cursor) {
      netbox.NetBoxArtManager art = new netbox.NetBoxArtManager(builder, backendAddr, apiKey, version: version, passwordKey: passwordKey);
      return art.findArticleWithUserName(userName, cursor);
    }
    ;
    return new NetBoxFeed(builder, backendAddr, apiKey,
        version: version,
        passwordKey: passwordKey, //
        funcfindArticle: adapter);
  }

  factory NetBoxFeed.tag(TinyNetBuilder builder, String tag, String subTag, String optTag, String backendAddr, String apiKey, //
      {String version: "v1",
      String passwordKey: "umiuni2d"}) {
    Future<netbox.NetBoxArtManagerFind> adapter(String cursor) {
      netbox.NetBoxArtManager art = new netbox.NetBoxArtManager(builder, backendAddr, apiKey, version: version, passwordKey: passwordKey);
      return art.findArticleFromTag(tag, subTag, optTag, cursor);
    }
    ;
    return new NetBoxFeed(builder, backendAddr, apiKey,
        version: version,
        passwordKey: passwordKey, //
        funcfindArticle: adapter);
  }

  Future<List<netbox.NetBoxArtManagerFindArt>> next() async {
    netbox.NetBoxArtManagerFind a = await this.funcfindArticle(this.tailCursor);
    if (a.code == netbox.NetBox.ReqPropertyCodeOK) {
      tailCursor = a.cursorNext;
    }
    for (var v in a.arts) {
      if (false == foundedHash.containsKey(v.articleId)) {
        foundedHash[v.articleId] = v;
        founded.add(v);
      }
    }
    return a.arts;
  }
}
