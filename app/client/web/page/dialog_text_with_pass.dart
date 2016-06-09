import 'dart:html' as html;
import 'dialog.dart';
import 'dart:async';

class TextDialogWithPass {
  Dialog base;
  String dialogName;
  String uploadBtnId;
  String closeBtn;
  String passId;
  String inputValueId;

  TextDialogWithPass(
      {this.dialogName: "dialog_load_text",
      this.uploadBtnId: "uploadBtn",
      this.closeBtn: "closeBtn", //
      this.passId: "passId",
      this.inputValueId: "inputValueId"}) {
    base = new Dialog(this.dialogName);
  }

  init() {
    base.init();
  }

  show({Future<bool> onUpdated(TextDialogWithPass dialog, String pass, String src): null, String type: "text"}) {
    html.ImageElement imageTmp = null;
    List<String> c = [
      """<h3>Text Edit</h3>""", //
      """<input placeholder="pass" type="password" id=${this.passId}><br>""",
      """<input placeholder="value" type="${type}" id=${this.inputValueId}><br><br>""",
      """<button id="${this.uploadBtnId}" style="display:inline; padding: 12px 24px;">upload</button>""",
      """<button id="${this.closeBtn}" style="display:inline; padding: 12px 24px;">close</button>""",
    ];
    html.DialogElement elm = base.show(c.join("\r\n"));
    var uploadBtn = elm.querySelector("#${this.uploadBtnId}");

    html.InputElement passElm = elm.querySelector("#${this.passId}");
    html.InputElement valueElm = elm.querySelector("#${this.inputValueId}");
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
          if (true == await onUpdated(this, passElm.value, valueElm.value)) {
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
