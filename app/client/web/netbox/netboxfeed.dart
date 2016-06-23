import "netboxart.dart" as netbox;
import "netbox.dart" as netbox;
import "dart:async";

typedef Future<netbox.NetBoxArtManagerFind> FuncfindArticle(String cursor);
class NetBoxFeed {
  String headCursor = "";
  String tailCursor = "";

  String backendAddr;
  String apiKey;
  String version;
  String passwordKey;
  FuncfindArticle  funcfindArticle;

  List<netbox.NetBoxArtManagerFindArt> founded = [];
  Map<String,netbox.NetBoxArtManagerFindArt> foundedHash = {};

  NetBoxFeed(this.backendAddr, this.apiKey, {this.version: "v1", this.passwordKey: "umiuni2d", //
    this.funcfindArticle:null}) {
      if(this.funcfindArticle == null) {
          netbox.NetBoxArtManager art = new netbox.NetBoxArtManager(backendAddr, apiKey);
        this.funcfindArticle = art.findArticleWithNewOrde;
      }
    }


  Future<List<netbox.NetBoxArtManagerFindArt>> next() async {
    netbox.NetBoxArtManagerFind a  = await this.funcfindArticle(this.tailCursor);
    if(a.code == netbox.NetBox.ReqPropertyCodeOK) {
      tailCursor = a.cursorNext;
    }
    for (var v in a.arts) {
      if( false == foundedHash.containsKey(v.articleId)) {
        foundedHash[v.articleId] = v;
        founded.add(v);
      }
    }
    return a.arts;
  }


}
