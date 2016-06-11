import 'dart:html' as html;
import 'dart:async';
import '../../netbox/netbox.dart' as nbox;
import '../../netbox/netboxme.dart' as nbox;
import '../../netbox/netboxfile.dart' as nbox;
import '../../netbox/status.dart' as nbox;

typedef Future<Map<String, Object>> PostCallback(PostStatus status, String title, String tag, String cont, String articleId);

typedef Future<String> LoadImageAction(html.TextAreaElement cont, String articleId);

enum PostStatus { save, public, hide }

class PostPage {
  String rootId;
  nbox.MyStatus status;
  nbox.NetBox netbox;

  PostPage(this.status, this.netbox, this.rootId) {
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
    //if (hash.startsWith("#/Me")) {
    //  if (hash == "#/Me") {
    //    update();
    //  }
    //}
  }

  update() {
    //
    html.Element elm = html.document.body.querySelector("#${this.rootId}");
    elm.children.clear();
    if (this.status.isLogin) {
      elm.appendHtml(
          [
            """<H2>${this.status.userName}</H2>""",
//            """ <br><button id="${this.logoutId}" style="display:inline; padding: 12px 24px;">Logout</button>""",

            ///
            """<H3>Icon</H3>""",
            """ <div>""", //
  //          """ <img id="${this.iconId}" style="display:inline; background-color:#99cc00;" src="${netbox.newMeManager().makeImgUserIconSrc(this.status.userName)}">""", //
  //          """ <br><button id="${this.editIconId}" style="display:inline; padding: 12px 24px;">Edit</button>""",
            """ </div>""", //
            //
          ].join(),
          treeSanitizer: html.NodeTreeSanitizer.trusted);
        }
  }
}
