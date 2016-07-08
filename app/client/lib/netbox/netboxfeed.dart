import "netboxart.dart" as netbox;
import "netbox.dart" as netbox;
import "dart:async";

typedef Future<netbox.NetBoxArtManagerFind> FuncfindArticle(String cursor);

class NetBoxFeedManager {
  String backendAddr;
  String apiKey;
  String version;
  String passwordKey;
  FuncfindArticle funcfindArticle;

  NetBoxFeed _newOrderBox = null;
  Map<String,NetBoxFeed> _tagBox = {};

  NetBoxFeedManager(this.backendAddr, this.apiKey,
      {this.version: "v1",
      this.passwordKey: "umiuni2d", //
      this.funcfindArticle: null}) {
        _newOrderBox = new NetBoxFeed(backendAddr, apiKey,version:this.version,
        passwordKey: this.passwordKey, funcfindArticle: null);
  }

  NetBoxFeed getNewOrder() {
    return _newOrderBox;
  }

  NetBoxFeed getFromTag(String tag) {
    var r = _tagBox[tag];
    if(r != null) {
      return r;
    }
    r = new NetBoxFeed.tag(tag, backendAddr, apiKey, version:this.version,
    passwordKey: this.passwordKey);
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

  NetBoxFeed(this.backendAddr, this.apiKey,
      {this.version: "v1",
      this.passwordKey: "umiuni2d", //
      this.funcfindArticle: null}) {
    if (this.funcfindArticle == null) {
      netbox.NetBoxArtManager art = new netbox.NetBoxArtManager(backendAddr, apiKey, version: version, passwordKey: passwordKey);
      this.funcfindArticle = art.findArticleWithNewOrde;
    }
  }

  factory NetBoxFeed.username(String userName, String backendAddr, String apiKey, //
      {String version: "v1",
      String passwordKey: "umiuni2d"}) {
    Future<netbox.NetBoxArtManagerFind> adapter(String cursor) {
      netbox.NetBoxArtManager art = new netbox.NetBoxArtManager(backendAddr, apiKey, version: version, passwordKey: passwordKey);
      return art.findArticleWithUserName(userName, cursor);
    }
    ;
    return new NetBoxFeed(backendAddr, apiKey,
        version: version,
        passwordKey: passwordKey, //
        funcfindArticle: adapter);
  }

  factory NetBoxFeed.tag(String tag, String backendAddr, String apiKey, //
      {String version: "v1",
      String passwordKey: "umiuni2d"}) {
    Future<netbox.NetBoxArtManagerFind> adapter(String cursor) {
      netbox.NetBoxArtManager art = new netbox.NetBoxArtManager(backendAddr, apiKey, version: version, passwordKey: passwordKey);
      return art.findArticleFromTag(tag, cursor);
    }
    ;
    return new NetBoxFeed(backendAddr, apiKey,
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
