import 'dart:html' as html;
import 'dialog.dart';
import 'dart:async';

class PostDialog {
  Dialog base;
  String dialogName;
  String naviId;

  PostDialog({//
    this.naviId:"naviId",
    String width:"300px",this.dialogName: "dialog_confirm"}) {
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
      """nav.${this.naviId} input {""", //
      """	display: flex;""", //
      """	flex-flow: row;""", //
      """ width:90%;""",
      """	margin: 0;""", //
      """	padding: 6px;""", //
      """	list-style-type: none;""", //
      """}""",
      """nav.${this.naviId} div {""", //
      """	display: flex;""", //
      """	flex-flow: row;""", //
      """ width:90%;""",
      """	margin: 0;""", //
      """	padding: 6px;""", //
      """	list-style-type: none;""", //
      """}"""

    ]);
  }

  show(String title, String message, {String okName: "OK", String cancelName: "Cancel",
   Future<bool> onUpdated(PostDialog dialog, bool okBtnIsSelected): null, String type: "text"}) {
   List<List<String>> stack = [];
   List<String> c = [
      """<nav class="${this.naviId}">""", //
      """		<ul id="plain-menu">""",
      """    <li><a href="#/back">Back</a></li>""",
      """		</ul>""", //
      """</nav>"""];
    c.addAll([
      """<nav class="${this.naviId}">""",
      """<input id="${this.naviId}_title" type="text" placeholder="Title">""", //
      """<div id="${this.naviId}_tag"><div>""",
      """</nav>""",
    ]);

    c.addAll([
      """<nav class="${this.naviId}">""",
      """<input id="${this.naviId}_title" type="text" placeholder="Title">""", //
      """<div id="${this.naviId}_tag"><div>""",
      """</nav>""",
    ]);

    html.DialogElement elm = base.show(c.join("\r\n"));

    //
    bool click = false;
    b(bool vvv) {
      return (_) async {
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

  }

  close() {
    base.close();
  }
}
