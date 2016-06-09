import 'dart:html' as html;
import 'dialog.dart';
import 'dart:async';

class PasswordDialog {
  Dialog base;
  String dialogName;
  String uploadBtnId;
  String closeBtn;
  String passId;
  String newpassId1;
  String newpassId2;

  PasswordDialog(
      {this.dialogName: "dialog_load_text",
      this.uploadBtnId: "uploadBtn",
      this.closeBtn: "closeBtn", //
      this.passId: "passId",
      this.newpassId1: "newpassId",
      this.newpassId2: "newpassId"}) {
    base = new Dialog(this.dialogName);
  }

  init() {
    base.init();
  }

  show({Future<bool> onUpdated(PasswordDialog dialog, String pass, String newpass1, String newpass2): null, String type: "text"}) {
    List<String> c = [
      """<h3>Text Edit</h3>""", //
      """<input placeholder="pass" type="password" id=${this.passId}><br>""",
      """<input placeholder="newpass" type="password" id=${this.newpassId1}><br>""",
      """<input placeholder="newpass to confirm" type="password" id=${this.newpassId2}><br>""",

      """<button id="${this.uploadBtnId}" style="display:inline; padding: 12px 24px;">upload</button>""",
      """<button id="${this.closeBtn}" style="display:inline; padding: 12px 24px;">close</button>""",
    ];
    html.DialogElement elm = base.show(c.join("\r\n"));
    var uploadBtn = elm.querySelector("#${this.uploadBtnId}");

    html.InputElement passElm = elm.querySelector("#${this.passId}");
    html.InputElement newpass1Elm = elm.querySelector("#${this.newpassId1}");
    html.InputElement newpass2Elm = elm.querySelector("#${this.newpassId2}");

    //
    bool click = false;
    uploadBtn.onClick.listen((_) async {
      if (click == true) {
        return;
      }
      click = true;
      uploadBtn.style.display = "none";
      try {
        if (onUpdated != null) {
          if (true == await onUpdated(this, passElm.value, newpass1Elm.value,newpass2Elm.value)) {
            this.close();
          }
        }
      } finally {
        click = false;
        uploadBtn.style.display = "inline";
      }
    });
    var closeBtn = elm.querySelector("#${this.closeBtn}");
    closeBtn.onClick.listen((_) {
      this.close();
    });
  }

  close() {
    base.close();
  }
}
