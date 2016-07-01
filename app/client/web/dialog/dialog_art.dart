import 'dart:html' as html;
import 'dialog.dart';
import 'dart:async';
import '../util/textbuilder.dart' as util;
import '../dialog/dialog_text.dart' as dialog;
import '../dialog/dialog_confirm.dart' as dialog;
import '../netbox/netbox.dart' as nbox;
import '../netbox/netboxart.dart' as nbox;
import '../netbox/status.dart' as nbox;
import 'package:markdown/markdown.dart' as markdown;

class ArtDialog {
  Dialog base;
  String dialogName;
  String naviId;
  nbox.NetBox netbox;
  nbox.MyStatus status;
  ArtDialog(this.status, this.netbox,
      { //
      this.naviId: "naviId",
      String width: "300px",
      this.dialogName: "dialog_art"}) {
    base = new Dialog(this.dialogName, width: width);
  }

  init() {
    base.init(optStyle: [
      """nav.${this.naviId}  {""", //
      """	background-color: #222222;""", //
      """	color: white;""", //
      """}""", //
      """nav.${this.naviId}  ul {""", //
      """	display: flex;""", //
      //"""	flex-flow: row;""", //
      """flex-wrap: wrap;""",
      """	margin: 0;""", //
      """	padding: 6px;""", //
      """	list-style-type: none;""", //
      """}""", //
      """nav.${this.naviId} a {""", //
      """	display: block;""", //
      """	border-radius: 4px;""", //
      """	padding: 12px 24px;""", //
      """	color: white;""", //
      """	text-decoration: none;""", //
      """}""", //
      """nav.${this.naviId} li a:hover {""", //
      """	background-color: #8cae47;""", //
      """}""",
      """nav.${this.naviId} input.text {""", //
      """	display: flex;""", //
      """	flex-flow: row;""", //
      """ width:90%;""",
      """	margin: 0;""", //
      """	padding: 6px;""", //
      """	list-style-type: none;""", //
      """}""",
      """nav.${this.naviId} textarea.textarea {""", //
      """	display: flex;""", //
      """	flex-flow: row;""", //
      """ width:90%;""",
      """ height:300px;""",
      """	margin: 0;""", //
      """	padding: 6px;""", //
      """	list-style-type: none;""", //
      """ text-align: left;""",
      """ vertical-align: top;""",
      """}""",
      """nav.${this.naviId} div {""", //
      """	display: flex;""", //
      """	flex-flow: row;""", //
      """ width:90%;""",
      """	margin: 0;""", //
      """	padding: 6px;""", //
      """	list-style-type: none;""", //
      """}""",
      """nav.${this.naviId} button {""", //
      """	display: block;""", //
      """	border-radius: 4px;""", //
      """	padding: 6px 12px;""", //
//      """	color: white;""", //
      """	text-decoration: none;""", //
      """}""",
      //
      """nav.${this.naviId} a.mini {""", //
      """	display: block;""", //
      //  """	border-radius: 2px;""", //
      """	padding: 3px 6px;""", //
      """	background-color: #cccccc;""", //
      """	color: Black;""", //
      """	text-decoration: none;""", //
      """}""", //
    ]);
  }

  addTag(List<String> tags, String tag) {
    html.Element d = base.getDialogElement().querySelector("#${this.naviId}_tag");
    html.Element b = new html.Element.html("<button>${tag}</button>");
    d.children.add(b);
    b.onClick.listen((_) {
      dialog.ConfirmDialog dd = new dialog.ConfirmDialog();
      dd.init();
      bool click = false;
      if (click == true) {
        return;
      }
      try {
        click = true;
        dd.show("Delete Tag", "", onUpdated: (dialog.ConfirmDialog dd, bool isOk) {
          print("------->");
          if (isOk == true) {
            tags.remove(tag);
            d.children.remove(b);
          }
          dd.close();
        });
      } catch (e) {} finally {
        click = false;
      }
    });
  }

  show(String articleId, String title, List<String> tags, String message, String state,
      {String okName: "OK",
      String cancelName: "Cancel", //
      String type: "text", //
      Future<bool> onUpdated(ArtDialog dialog, bool okBtnIsSelected): null}) {
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
    util.TextBuilderTicket tag = builder.pat(navi, ["""<div id="${this.naviId}_tag">"""], ["""</div>"""]);

    for (String t in tags) {
      builder.end(tag, [""" <a class="mini" href="#/Article?tag=${Uri.encodeComponent(t)}">""", """ <div class="mini">${t}</div></a>"""]);
    }
    print("tags----> ${tags}");
    //
    //
    print("---> ${message}");
    if (message == null) {
      message = "";
    }
    builder.end(builder.getRootTicket(), [markdown.markdownToHtml(message)]);
    var comments = builder.pat(builder.getRootTicket(), ["<div>"], ["</div>"]);
    if (status.isLogin == true) {
      builder.end(builder.getRootTicket(), [
        """<nav class="${this.naviId}">""",
        """<H4>Comments</H4>""", //
        """		<ul id="plain-menu">""",
        """    <li><a id="comment">Send</a></li>""",
        """    <li><a id="none"></a></li>""",
        """		</ul>""", //
        """<textarea id="${this.naviId}_cont" class="textarea"></textarea>""",
        """</nav>"""
      ]);
    }
    html.DialogElement elm = base.show(builder.toText("\r\n"));
    elm.querySelector("#back").onClick.listen((_) {
      this.close();
      html.window.history.back();
    });
    elm.querySelector("#comment").onClick.listen((_) {
      dialog.ConfirmDialog d = new dialog.ConfirmDialog();
      d.init();
      d.show("Send Comment", "Are you ok?", onUpdated: (dialog.ConfirmDialog dialog, bool okBtnIsSelected) {
        print("== ${okBtnIsSelected}");
        return true;
      });
    });
  }

  close() {
    base.close();
  }
}
