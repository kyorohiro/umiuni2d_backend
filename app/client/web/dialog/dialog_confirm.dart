import 'dart:html' as html;
import 'dialog.dart';
import 'dart:async';

class ConfirmDialog {
  Dialog base;
  String dialogName;
  String okBtnId;
  String cancelBtnId;

  ConfirmDialog({this.dialogName: "dialog_confirm", this.okBtnId: "uploadBtn", this.cancelBtnId: "closeBtn"}) {
    base = new Dialog(this.dialogName);
  }

  init() {
    base.init();
  }

  show(String title, String message, {String okName: "OK", String cancelName: "Cancel", Future<bool> onUpdated(ConfirmDialog dialog, bool okBtnIsSelected): null, String type: "text"}) {
    List<String> c = [
      """<h3>${title}</h3>""", //
      """<div>${message}</div>""", //
      """<button id="${this.okBtnId}" style="display:inline; padding: 12px 24px;">${okName}</button>""",
      """<button id="${this.cancelBtnId}" style="display:inline; padding: 12px 24px;">${cancelName}</button>""",
    ];
    print("---->ssa");
    html.DialogElement elm = base.show(c.join("\r\n"));
    print("---->ssa");
    var okBtn = elm.querySelector("#${this.okBtnId}");
    var cancelBtn = elm.querySelector("#${this.cancelBtnId}");

    //
          print("---->ssa");
    bool click = false;
    b(bool vvv) {
      return (_) async {
        print("---->ss");
        if (click == true) {
          return false;
        }
        bool ret = true;
        try {
          click = true;
          ret = await onUpdated(this, vvv);
        } finally {
          click = false;
        }
        if(ret == true) {
          this.close();
        }
        return ret;
      };
    }

    okBtn.onClick.listen(b(true));
    cancelBtn.onClick.listen(b(false));
  }

  close() {
    base.close();
  }
}
