import 'dart:html' as html;

//
class Toolbar {
  init() {
    makeToolbar([], []);
    makeMain();
  }

  makeMain() {
    html.document.body.appendHtml([
      """<div id="main">""", //
      """</div>"""
    ].join("\r\n"));
  }

  updateToolbar(List<String> titles, List<String> hashs) {
    html.UListElement u = html.document.body.querySelector("#plain-menu");
    u.children.clear();
    List a = [];
    for (int i = 0; i < titles.length; i++) {
      a.addAll([
        """	 <li><a href="#/${hashs[i]}">${titles[i]}</a></li>""", //
      ]);
    }
    u.appendHtml(a.join("\r\n"));
  }

  makeToolbar(List<String> titles, List<String> hashs) {
    html.StyleElement styleElement = new html.StyleElement();
    styleElement.type = "text/css";
    styleElement.text = [
      """.atoolbar body {""", //
      """  font-family: sans-serif;""", //
      """}""", //
      """nav.atoolbar  {""", //
      """	background-color: #222222;""", //
      """	color: white;""", //
      """	display: flex;""", //
      """}""", //
      """nav.atoolbar  ul {""", //
      """	display: flex;""", //
    //  """	flex-flow: row;""", //
      """flex-wrap: wrap;""",
      """	margin: 0;""", //
      """	padding: 6px;""", //
      """	list-style-type: none;""", //
      """}""", //
      """nav.atoolbar  a {""", //
      """	display: flex;""", //
      """	border-radius: 4px;""", //
      """	padding: 12px 24px;""", //
      """	color: white;""", //
      """	text-decoration: none;""", //
      """}""", //
      """nav.atoolbar  li a:hover {""", //
      """	display: flex;""", //
      """	background-color: #8cae47;""", //
      """}"""
    ].join("\r\n"); //
    html.document.head.append(styleElement);
    var a = [];
    a.addAll([
      """<nav class="atoolbar">""", //
      """		<ul id="plain-menu">""",
    ]); //
/*
    for (int i = 0; i < titles.length; i++) {
      a.addAll([
        """				<li><a href="#/${Uri.encodeComponent(hashs[i])}">${titles[i]}</a></li>""", //
      ]);
    }*/
    a.addAll([
      """		</ul>""", //
      """</nav>"""
    ]);
    html.document.body.appendHtml(a.join("\r\n")); //

    updateToolbar(titles, hashs);
  }
}
