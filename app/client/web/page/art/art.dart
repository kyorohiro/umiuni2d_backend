import 'dart:html' as html;
import 'dart:async';
import '../../netbox/netbox.dart' as nbox;
import '../../netbox/netboxme.dart' as nbox;
import '../../netbox/netboxfile.dart' as nbox;
import '../../netbox/netboxart.dart' as nbox;
import '../../netbox/status.dart' as nbox;
import '../../dialog/dialog_post.dart' as dialog;
import '../../dialog/dialog_art.dart' as dialog;
import '../../util/textbuilder.dart' as util;

class ArtPage {
  String rootId;
  String naviId;
  String iconId;
  nbox.MyStatus status;
  nbox.NetBox netbox;

  ArtPage(this.status, this.netbox, this.rootId, {this.naviId: "bbnaviId", this.iconId: "bbiconId"}) {
    html.window.onHashChange.listen((_) {
      updateFromHash();
    });
    init();
  }

  Future updateFromHash() async {
    if (this.status.isLogin == false) {
      return;
    }
    String hash = html.window.location.hash;
    Map<String,String> prop = {};
    if (hash.indexOf("?") > 0) {
      prop = Uri.splitQueryString(hash.substring(hash.indexOf("?") + 1));
      hash = hash.substring(0, hash.indexOf("?"));
    }
    if (hash.startsWith("#/Article")) {
      if (hash == "#/Article/get") {
        if (prop[nbox.NetBox.ReqPropertyArticleId] != null) {
          update(prop[nbox.NetBox.ReqPropertyArticleId]);
        }
      }
    }
  }

  init(){
  }

  update(String articleId) async {
    print("=====> ${articleId}");
    nbox.NetBoxArtManagerFindArt art =  await netbox.newArtManager().getArticleFromArticleId(articleId);
    dialog.ArtDialog d = new dialog.ArtDialog(status, netbox, width: "90%");
    d.init();
    d.show(articleId, art.title, ["tags"], art.cont, art.state);
  }
}
