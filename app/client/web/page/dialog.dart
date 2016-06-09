import 'dart:html' as html;
import 'imageutil.dart';

class ImgageDialog {
  Dialog base;
  String dialogName;
  String fileBtnId;
  String uploadBtnId;
  String closeBtn;
  ImgageDialog({this.dialogName: "dialog_load_img", this.fileBtnId: "fileBtn",
   this.uploadBtnId: "uploadBtn", this.closeBtn: "closeBtn"}) {
    base = new Dialog(this.dialogName);
  }

  init() {
    base.init();
  }

  show() {
    html.ImageElement imageTmp = null;
    List<String> c = [
      """<h3>Image Uploader</h3>""", //
      """<input id="${this.fileBtnId}" style="display:block" type="file">""",
      """<button id="${this.uploadBtnId}" style="display:none; padding: 12px 24px;">upload</button>""",
      """<button id="${this.closeBtn}" style="display:inline; padding: 12px 24px;">close</button>""",
    ];
    html.DialogElement elm = base.show(c.join("\r\n"));
    var uploadBtn = elm.querySelector("#${this.uploadBtnId}");
    uploadBtn.onClick.listen((_){
      print("---");
    });
    var closeBtn = elm.querySelector("#${this.closeBtn}");
    closeBtn.onClick.listen((_){
      print("---");
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

class Dialog {
  String dialogName;
  Dialog(this.dialogName) {}

  html.DialogElement show(String cont) {
    html.DialogElement dialog = html.document.body.querySelector('#${dialogName}');
    dialog.children.clear();
    dialog.appendHtml(cont, treeSanitizer: html.NodeTreeSanitizer.trusted);
    dialog.showModal();
    return dialog;
  }

  close() {
    html.DialogElement dialog = html.document.body.querySelector('#${dialogName}');
    dialog.close("ok");
  }

  init() {
    html.StyleElement styleElement = new html.StyleElement();
    styleElement.type = "text/css";
    styleElement.text = [
      """dialog.${dialogName} {""", //
      """  background: #FFF;""", //
      """  width: 300px;""", //
      """  text-align: center;""", //
      """  padding: 1.5em;""", //
      """  margin: 1em auto;""", //
      """  border: 0;""", //
      """  border-top: 5px solid #69c773;""", //
      """  box-shadow: 0 2px 10px rgba(0,0,0,0.8);""", //
      """}""", //
      """dialog.${dialogName}::backdrop {""", //
      """  position: fixed;""", //
      """  top: 0;""", //
      """  left: 0;""", //
      """  right: 0;""", //
      """  bottom: 0;""", //
      """  background-color: rgba(0, 0, 0, 0.8);""", //
      """}"""
    ].join("\r\n"); //
    html.Element elm = html.document.body;
    html.document.head.append(styleElement);

    elm.appendHtml(
        [
          """<dialog class="${dialogName}" id="${dialogName}">""", //
          """</dialog>""", //
          //
        ].join(),
        treeSanitizer: html.NodeTreeSanitizer.trusted);
  }
}
