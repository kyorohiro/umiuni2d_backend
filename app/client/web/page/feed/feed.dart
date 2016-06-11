import 'dart:html' as html;
import 'dart:async';
import '../../netbox/netbox.dart' as nbox;
import '../../netbox/netboxme.dart' as nbox;
import '../../netbox/netboxfile.dart' as nbox;
import '../../netbox/status.dart' as nbox;
import '../../dialog/dialog_post.dart' as dialog;
class FeedPage {
  String rootId;
  nbox.MyStatus status;
  nbox.NetBox netbox;

  FeedPage(this.status, this.netbox, this.rootId) {
    html.window.onHashChange.listen((_) {
      updateFromHash();
    });
  }

  Future updateFromHash() async {
    if (this.status.isLogin == false) {
      return;
    }
    String hash = html.window.location.hash;
// prop = {};
    if (hash.indexOf("?") > 0) {
//      prop = Uri.splitQueryString(hash.substring(hash.indexOf("?") + 1));
      hash = hash.substring(0, hash.indexOf("?"));
    }
    if (hash.startsWith("#/Article")) {
      if (hash == "#/Article") {
        update();
      }
      if (hash == "#/Article/post") {
        //.update();
        dialog.PostDialog d = new dialog.PostDialog(width: "100%");
        d.init();
        d.show("title", "message<br>asdff<br>asdf<br>asasdf<br><br><br><br><br><br>asdafsdf");
      }
    }
  }

  update() {
    //
    html.Element elm = html.document.body.querySelector("#${this.rootId}");
    elm.children.clear();
    elm.appendHtml(
        [
          """<H2>${this.status.userName}</H2>""",

          ///
          """<H3>Icon</H3>""",
          """ <div>""", //
          """ </div>""", //
          //
        ].join(),
        treeSanitizer: html.NodeTreeSanitizer.trusted);
    //
    //
    if (this.status.isLogin) {
      //target="_blank"
      elm.appendHtml(["""<a href="#/Article/post" id="view-source">""", """Post</a>"""].join("\r\n"));
    }
  }
}
