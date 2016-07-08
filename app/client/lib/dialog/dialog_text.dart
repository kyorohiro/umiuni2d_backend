import 'dart:html' as html;
import 'dialog.dart';
import 'dart:async';

class TextDialog {
  Dialog base;
  String dialogName;
  String uploadBtnId;
  String closeBtn;
  String passId;
  String inputValueId;

  TextDialog(
      {this.dialogName: "dialog_load_text",
      this.uploadBtnId: "uploadBtn",
      this.closeBtn: "closeBtn", //
      this.inputValueId: "inputValueId"}) {
    base = new Dialog(this.dialogName);
  }

  init() {
    base.init();
  }

  show(String title, String message, {Future<bool> onUpdated(TextDialog dialog, String src): null, String type: "text"}) {
    List<String> c = [
      """<h3>${title}</h3>""", //
      """<div>${message}</div>""",
      """<input placeholder="value" type="${type}" id=${this.inputValueId}><br><br>""",
      """<button id="${this.uploadBtnId}" style="display:inline; padding: 12px 24px;">upload</button>""",
      """<button id="${this.closeBtn}" style="display:inline; padding: 12px 24px;">close</button>""",
    ];
    html.DialogElement elm = base.show(c.join("\r\n"));
    var uploadBtn = elm.querySelector("#${this.uploadBtnId}");

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
          if (true == await onUpdated(this, valueElm.value)) {
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
