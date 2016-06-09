import 'dart:html' as html;
import 'dart:async';
import '../netbox/netbox.dart' as nbox;
import '../netbox/netboxme.dart' as nbox;
import '../netbox/netboxfile.dart' as nbox;
import '../netbox/status.dart' as nbox;
import 'dialog_image.dart' as dialog;
import 'dialog_text_with_pass.dart' as dialog;


class MePage {
  String rootId;
  String editIconId;
  String editMailId;

  nbox.MyStatus status;
  nbox.NetBox netbox;
  static String propUserName = "userName";
  static String propPassword = "password";

  MePage(this.status, this.netbox, this.rootId, //
      {this.editIconId: "editIconBtn",
      this.editMailId: "editMailBtn"}) {
    init();
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
    if (hash.startsWith("#/Me")) {
      if (hash == "#/Me") {
        update();
      }
    }
  }

  init() {
    html.StyleElement styleElement = new html.StyleElement();
    styleElement.type = "text/css";
    styleElement.text = [
      """nav.mepage  {""", //
      """	background-color: #222222;""", //
      """	color: white;""", //
      """}""", //
      """nav.mepage ul {""", //
      //  """	display: flex;""", //
      """	flex-flow: row;""", //
      """	margin: 0;""", //
      """	padding: 6px;""", //
      """	list-style-type: none;""", //
      """}""", //
      """nav.mepage a {""", //
      """	display: block;""", //
      """	border-radius: 4px;""", //
      """	padding: 12px 24px;""", //
      """	color: white;""", //
      """	text-decoration: none;""", //
      """}""", //
      """nav.mepage li a:hover {""", //
      """	background-color: #8cae47;""", //
      """}"""
    ].join("\r\n"); //
    html.document.head.append(styleElement);
  }

  update() async {
    html.Element elm = html.document.body.querySelector("#${this.rootId}");
    elm.children.clear();
    if (this.status.isLogin) {
      elm.appendHtml(
          [
            """<H3>${this.status.userName}</H3>""",
            """<H5>Icon</H3>""",
            //
            """ <div>""", //
            """ <img id="icon" style="display:inline; background-color:#99cc00;" src="${netbox.newMeManager().makeImgUserIconSrc(this.status.userName)}">""", //
            """ <br><button id="${this.editIconId}" style="display:inline; padding: 12px 24px;">Edit</button>""",
            """ </div>""", //
            //
          ].join(),
          treeSanitizer: html.NodeTreeSanitizer.trusted);
      //
      elm.querySelector("#${editIconId}").onClick.listen((_) {
        dialog.ImgageDialog imgDialog = new dialog.ImgageDialog();
        imgDialog.init();
        imgDialog.show(onUpdated: (dialog.ImgageDialog d, String src) async {
          var r = await netbox.newFileShareManager().fileShare(src, "meicon", status.userObjectId);
          return (r.code == nbox.NetBox.ReqPropertyCodeOK);
        });
      });
      //
      //
      nbox.NetBoxMeManagerGetInfo rt = await this.netbox.newMeManager().getMyInfo(status.userObjectId);
      //rt.code;
      //rt.requestId;
      //rt.mail;
      //rt.name;
      // this.editMailId
      elm.appendHtml(
          [
            //
            """<H5>EMail</H5>""",
            """ <div>""", //
            """  <div>${rt.mail}</div>""", //
            """  <br><button id="${this.editMailId}" style="display:inline; padding: 12px 24px;">Edit</button>""",
            """ </div>""", //
            //
          ].join(),
          treeSanitizer: html.NodeTreeSanitizer.trusted);
      elm.querySelector("#${this.editMailId}").onClick.listen((_) {
        dialog.TextDialogWithPass d = new dialog.TextDialogWithPass();
        d.init();
        d.show(onUpdated: (dialog.TextDialogWithPass d, String pass, String v) async{
          print("--> ${pass} ${v}");
          return true;
        });
      });
    }
  }
}
