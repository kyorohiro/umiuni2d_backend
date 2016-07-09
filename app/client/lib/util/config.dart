import 'dart:html' as html;

class TinyStyleElement {
  String styleId;
  String src;
  html.StyleElement styleElement;
  TinyStyleElement(this.styleId, this.src) {}

  compile() {
    if (this.styleElement == null) {
      this.styleElement = new html.StyleElement();
      this.styleElement.type = "text/css";
      this.styleElement.id = this.styleId;
      this.styleElement.text = src; //
      html.document.head.append(this.styleElement);
    }
  }

  delete() {
    html.HeadElement head = html.document.head.querySelector("#${this.styleId}");
    head.children.remove(styleElement);
    styleElement = null;
  }
}

class Config {
  static Config _baseInst = new Config();
  static Config get baseInst => _baseInst;
  TinyStyleElement addStyle(String id, String src) {
    return new TinyStyleElement(id, src)..compile();
  }
}

/*
    var o = [
     """nav.${this.naviId}  {""", //
     """	background-color: #222222;""", //
     """	color: white;""", //
     """}""", //
     """nav.${this.naviId}  ul {""", //
     """	display: flex;""", //
     //"""	flex-flow: row;""", //
     """flex-wrap: wrap;""",
     """	margin: 2px;""", //
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
     """nav.${this.naviId} li a {""", //
     """	margin: 2px;""", //
     """	background-color: #444444;""", //
     """}""",
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
     """	display: inline-flex;""", //
     """	flex-flow: row;""", //
     """ width:90%;""",
     """ height:800px;""",
     """	margin: 0;""", //
     """	padding: 6px;""", //
     """	list-style-type: none;""", //
     """ text-align: left;""",
     """ vertical-align: top;""",
     """}""",
     """nav.${this.naviId} div.title {""", //
     """	display: inline-flex;""", //
     """	flex-flow: row;""", //
     """ width:90%;""",
     """	margin: 0;""", //
     """	padding: 6px;""", //
     """	list-style-type: none;""", //
     """}""",
     """nav.${this.naviId} button {""", //
     """	display: inline-flex;""", //
     """	border-radius: 4px;""", //
     """	padding: 6px 12px;""", //
//      """	color: white;""", //
     """	text-decoration: none;""", //
     """}""",
   ];
 */
