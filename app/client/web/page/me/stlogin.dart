import 'dart:html' as html;
import 'dart:async';
import 'package:umiuni2d_backend_client/nbox.dart' as nbox;
import 'package:umiuni2d_backend_client/dialog.dart' as dialog;


class MePage {
  String rootId;
  String logoutId;
  String editIconId;
  String editMailId;
  String editPasswordId;
  String iconId;

  nbox.MyStatus status;
  nbox.NetBox netbox;
  static String propUserName = "userName";
  static String propPassword = "password";

  MePage(this.status, this.netbox, this.rootId, //
      {this.logoutId: "logoutId",
      this.editIconId: "editIconBtn",
      this.editMailId: "editMailBtn", //
      this.iconId: "iconId",
      this.editPasswordId: "editPasswordId"}) {
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
      name(elm);
      nbox.NetBoxMeManagerGetInfo rt = await this.netbox.newMeManager().getMyInfo(status.userObjectId);
      mail(rt.mail, elm);
      password(elm);
      arts(elm);
    }
  }
  arts(html.Element elm) {
    print("-3");
    elm.appendHtml(
        [
          """<H3>Arts</H3>""",
          //""" <div>""", //
          //""" </div>""", //
          //
        ].join(),
        treeSanitizer: html.NodeTreeSanitizer.trusted);
  }
  name(html.Element elm) {
    elm.appendHtml(
        [
          """<H2>${this.status.userName}</H2>""",
          """ <br><button id="${this.logoutId}" style="display:inline; padding: 12px 24px;">Logout</button>""",

          ///
          """<H3>Icon</H3>""",
          """ <div>""", //
          """ <img id="${this.iconId}" style="display:inline; background-color:#99cc00;" src="${netbox.newMeManager().makeImgUserIconSrc(this.status.userName)}">""", //
          """ <br><button id="${this.editIconId}" style="display:inline; padding: 12px 24px;">Edit</button>""",
          """ </div>""", //
          //
        ].join(),
        treeSanitizer: html.NodeTreeSanitizer.trusted);
    //
    elm.querySelector("#${logoutId}").onClick.listen((_) {
      dialog.ConfirmDialog d = new dialog.ConfirmDialog();
      d.init();
      d.show("Logout", "Really OK. Logout", onUpdated: (dialog.ConfirmDialog d, bool o) async {
        if (o == false) {
          return true;
        }
        try {
          await netbox.newMeManager().logout(status.userObjectId);
        } catch (e) {}
        status.userObjectId = "";
        status.userName = "";
        html.window.location.assign("#/Home");
        return true;
      });
    });
    elm.querySelector("#${editIconId}").onClick.listen((_) {
      dialog.ImgageDialog imgDialog = new dialog.ImgageDialog();
      imgDialog.init();
      imgDialog.show(onUpdated: (dialog.ImgageDialog d, String src) async {
        var r = await netbox.newFileShareManager().fileShare(src, "meicon", status.userObjectId);
        if (r.code == nbox.NetBox.ReqPropertyCodeOK) {
          print("---<<<>>>>> ${r.blobKey}");
          html.ImageElement imgElm = elm.querySelector("#${this.iconId}");
          imgElm.src = netbox.newFileShareManager().makeUrlFromBlobKey(r.blobKey);
          return true;
        } else {
          return false;
        }
      });
    });
  }
  mail(String mail, html.Element elm) {
    print("-2");
    elm.appendHtml(
        [
          //
          """<H3>Mail</H3>""",
          """ <div>""", //
          """  <div>${mail}</div>""", //
          """  <br><button id="${this.editMailId}" style="display:inline; padding: 12px 24px;">Edit</button>""",
          """ </div>""", //
          //
        ].join(),
        treeSanitizer: html.NodeTreeSanitizer.trusted);
    elm.querySelector("#${this.editMailId}").onClick.listen((_) {
      dialog.TextDialogWithPass d = new dialog.TextDialogWithPass();
      d.init();
      d.show(onUpdated: (dialog.TextDialogWithPass d, String pass, String mail) async {
        var r = await netbox.newMeManager().mail(status.userName, mail, pass, status.userObjectId);
        if (r.code == nbox.NetBox.ReqPropertyCodeOK) {
          return true;
        } else {
          return false;
        }
      });
    });
  }

  password(html.Element elm)  {
    elm.appendHtml(
        [
          //
          """<H3>Password</H3>""",
          """ <div>""", //
          """  <button id="${this.editPasswordId}" style="display:inline; padding: 12px 24px;">Edit</button>""",
          """ </div>""", //
          //
        ].join(),
        treeSanitizer: html.NodeTreeSanitizer.trusted);
    elm.querySelector("#${this.editPasswordId}").onClick.listen((_) {
      dialog.PasswordDialog d = new dialog.PasswordDialog();
      d.init();
      d.show(onUpdated: (dialog.PasswordDialog dialog, String pass, String newpass1, String newpass2) async {
        if (newpass1 != newpass2) {
          return false;
        }
        var r = await netbox.newMeManager().password(status.userName, newpass1, pass, status.userObjectId);
        if (r.code == nbox.NetBox.ReqPropertyCodeOK) {
          return true;
        } else {
          return false;
        }
      });
    });
  }
}
