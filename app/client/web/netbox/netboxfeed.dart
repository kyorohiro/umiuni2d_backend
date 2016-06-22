import "netboxart.dart" as netbox;
import "netbox.dart" as netbox;
import "dart:async";

class NetBoxFeed {
  String headCursor = "";
  String tailCursor = "";

  String backendAddr;
  String apiKey;
  String version;
  String passwordKey;

  List<netbox.NetBoxArtManagerFindArt> founded = [];
  Map<String,netbox.NetBoxArtManagerFindArt> foundedHash = {};

  NetBoxFeed(this.backendAddr, this.apiKey, {this.version: "v1", this.passwordKey: "umiuni2d"}) {}


  Future<List<netbox.NetBoxArtManagerFindArt>> next() async {
    netbox.NetBoxArtManager art = new netbox.NetBoxArtManager(backendAddr, apiKey);
    netbox.NetBoxArtManagerFind a  = await art.findArticleWithNewOrde(tailCursor);
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
