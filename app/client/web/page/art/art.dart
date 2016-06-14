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
import '../../util/location.dart' as util;

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
    var hash = util.Location.address(html.window.location.hash);
    var prop = util.Location.prop(html.window.location.hash);
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
    nbox.NetBoxArtManagerFindArt art =  await netbox.newArtManager().getArticleFromArticleId(articleId);
    dialog.ArtDialog d = new dialog.ArtDialog(status, netbox, width: "90%");
    d.init();
    d.show(articleId, art.title, ["tags"], art.cont, art.state);
  }
}
