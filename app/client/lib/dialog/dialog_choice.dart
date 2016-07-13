import 'dart:html' as html;
import 'dialog.dart';
import 'dart:async';
import '../util/textbuilder.dart' as util;
import '../dialog/dialog_text.dart' as dialog;
import '../dialog/dialog_confirm.dart' as dialog;
import 'package:umiuni2d_backend_client/nbox.dart' as nbox;
import 'package:markdown/markdown.dart' as markdown;

class ChoiceDialog {
  Dialog base;
  String dialogName;
  String naviId;
  nbox.NetBox netbox;
  nbox.MyStatus status;
  ChoiceDialog(this.status, this.netbox,
      { //
      this.naviId: "naviId",
      String width: "300px",
      this.dialogName: "dialog_art"}) {
    base = new Dialog(this.dialogName, width: width);
  }

  init() {
    base.init();
  }

  show(String title, String message, List<String> choices,
      {String okName: "OK",
      String cancelName: "Cancel", //
      String type: "text", //
      Future<bool> onUpdated(ChoiceDialog dialog, String choice): null}) {
    try {
      base.close();
    } catch (e) {}
    util.TextBuilder builder = new util.TextBuilder();
    builder.end(builder.getRootTicket(), [
      """<nav class="${this.naviId}">""", //
      """		<ul id="plain-menu">""",
      """    <li><a id="back">Back</a></li>""",
      //
      """    <li><a id="none"></a></li>""",

      //
      """		</ul>""", //
      """</nav>"""
    ]);
    util.TextBuilderTicket navi = builder.pat(builder.getRootTicket(), [
      """<nav class="${this.naviId}">""",
      """<H2>${title}</H2>""", //
    ], [
      """</nav>"""
    ]);
    //
    for (var v in choices) {
      builder.end(navi, ["""<ul><li><a id="${Uri.encodeComponent(v)}"> ${v}""", """</a></li></ul>"""]);
    }
    //
    //
    html.DialogElement elm = base.show(builder.toText("\r\n"));
    //
    //

    //
    elm.querySelector("#back").onClick.listen((_) {
      this.close();
      html.window.history.back();
    });
    for (var v in choices) {
      elm.querySelector("#${Uri.encodeComponent(v)}").onClick.listen((_) {
        onUpdated(this, v);
      });
    }
  }

  close() {
    base.close();
  }
}
