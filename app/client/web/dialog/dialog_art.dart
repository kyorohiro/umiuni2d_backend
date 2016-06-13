import 'dart:html' as html;
import 'dialog.dart';
import 'dart:async';
import '../util/textbuilder.dart' as util;
import '../dialog/dialog_text.dart' as dialog;
import '../dialog/dialog_confirm.dart' as dialog;
import '../netbox/netbox.dart' as nbox;
import '../netbox/netboxart.dart' as nbox;
import '../netbox/status.dart' as nbox;


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
      """ height:800px;""",
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
      """    <li><a id="save">Save</a></li>""",
      """    <li><a id="public">Public</a></li>""",

      //
      """		</ul>""", //
      """</nav>"""
    ]);
    util.TextBuilderTicket navi = builder.pat(builder.getRootTicket(), [
      """<nav class="${this.naviId}">""",
      """<input class="text" id="${this.naviId}_title" type="text" placeholder="Title">""", //
    ], [
      """</nav>"""
    ]);
    util.TextBuilderTicket tag = builder.pat(navi, ["""<div id="${this.naviId}_tag">"""], ["""</div>"""]);

    builder.end(tag, ["""<button id="${this.naviId}_addtag">add tag</button>""",]);
    builder.end(navi, ["""<textarea id="${this.naviId}_cont" class="textarea"></textarea>""",]);

    html.DialogElement elm = base.show(builder.toText("\r\n"));
    elm.querySelector("#${this.naviId}_addtag").onClick.listen((_) {
      dialog.TextDialog d = new dialog.TextDialog();
      d.init();
      d.show("Add Tag", "", onUpdated: (dialog.TextDialog d, String v) {
        if (false == tags.contains(v)) {
          addTag(tags, v);
          tags.add(v);
        }
        return true;
      });
    });
    //
    //
    html.TextAreaElement contElm = elm.querySelector("#${this.naviId}_cont");
    html.InputElement titleElm = elm.querySelector("#${this.naviId}_title");

    elm.querySelector("#back").onClick.listen((_) {
      this.close();
    });

    elm.querySelector("#save").onClick.listen((_) {
      netbox.newArtManager().post(
          status.userName,
          status.userObjectId, //
          "",
          titleElm.value,
          tags.join(" "),
          contElm.value,
          "save");
    });

    elm.querySelector("#public").onClick.listen((_) async {
      nbox.NetBoxArtManagerPost ret =  await netbox.newArtManager().post(
          status.userName,
          status.userObjectId, //
          articleId,
          titleElm.value,
          tags.join(" "),
          contElm.value,
          (state == "private" ? "public" : "private"));
      if(ret.code == nbox.NetBox.ReqPropertyCodeOK) {
        state = ret.articleState;
        articleId = ret.articleId;
        elm.querySelector("#public").text = (state == "private" ? "public" : "hide");
      } else {
        ;
      }
    });
  }

  close() {
    base.close();
  }
}
