import 'dart:html' as html;

class Dialog {
  String dialogName;
  String width;
  Dialog(this.dialogName,{this.width:"300px"}) {}


  html.DialogElement show(String cont) {
    html.DialogElement dialog = html.document.body.querySelector('#${dialogName}');
    dialog.children.clear();
    dialog.appendHtml(cont, treeSanitizer: html.NodeTreeSanitizer.trusted);
    dialog.showModal();
    return dialog;
  }
  html.DialogElement getDialogElement() {
    return html.document.body.querySelector('#${dialogName}');
  }
  close() {
    html.DialogElement dialog = html.document.body.querySelector('#${dialogName}');
    dialog.close("ok");
  }

  init({List<String> optStyle:null}) {
    html.StyleElement styleElement = new html.StyleElement();
    styleElement.type = "text/css";
    var o = [
      """dialog.${dialogName} {""", //
      """  background: #FFF;""", //
      """  width: ${this.width};""", //
    //  """  text-align: center;""", //
      """  padding: 1.5em;""", //
      """  margin: 1em auto;""", //
            """  top: 0px;""", //
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
    ];
    if(optStyle != null) {
      o.addAll(optStyle);
    }
    styleElement.text = o.join("\r\n"); //
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
