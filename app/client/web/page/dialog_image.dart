import 'dart:html' as html;
import 'imageutil.dart';
import 'dialog.dart';
import 'dart:async';

class ImgageDialog {
  Dialog base;
  String dialogName;
  String fileBtnId;
  String uploadBtnId;
  String closeBtn;

  ImgageDialog({this.dialogName: "dialog_load_img", this.fileBtnId: "fileBtn", this.uploadBtnId: "uploadBtn", this.closeBtn: "closeBtn"}) {
    base = new Dialog(this.dialogName);
  }

  init() {
    base.init();
  }

  show({Future<bool> onUpdated(ImgageDialog dialog, String src): null}) {
    html.ImageElement imageTmp = null;
    List<String> c = [
      """<h3>Image Uploader</h3>""", //
      """<input id="${this.fileBtnId}" style="display:block" type="file">""",
      """<button id="${this.uploadBtnId}" style="display:none; padding: 12px 24px;">upload</button>""",
      """<button id="${this.closeBtn}" style="display:inline; padding: 12px 24px;">close</button>""",
    ];
    html.DialogElement elm = base.show(c.join("\r\n"));
    var uploadBtn = elm.querySelector("#${this.uploadBtnId}");

    //
    bool click = false;
    uploadBtn.onClick.listen((_) async {
      if(click == true) {
        return;
      }
      click = true;
      uploadBtn.style.display = "none";
      try {
        if (onUpdated != null) {
          if(true == onUpdated(this, imageTmp.src)) {
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
    var fileBtn = elm.querySelector("#${this.fileBtnId}");
    fileBtn.onChange.listen((html.Event e) async {
      if (fileBtn.files.length == 0) {
        return;
      }
      fileBtn.style.display = "none";
      uploadBtn.style.display = "inline";
      imageTmp = await ImageUtil.resizeImage(await ImageUtil.loadImage(fileBtn.files[0]));
      imageTmp.id = "currentImage";
      elm.children.add(imageTmp);
    });
  }

  close() {
    base.close();
  }
}
