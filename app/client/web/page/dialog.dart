import 'dart:html' as html;

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
