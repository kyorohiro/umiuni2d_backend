import 'dart:html' as html;

//
class BaseLine {

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
      """}""", //
      """nav.atoolbar  ul {""", //
      """	display: flex;""", //
      """	flex-flow: row;""", //
      """	margin: 0;""", //
      """	padding: 6px;""", //
      """	list-style-type: none;""", //
      """}""", //
      """nav.atoolbar  a {""", //
      """	display: block;""", //
      """	border-radius: 4px;""", //
      """	padding: 12px 24px;""", //
      """	color: white;""", //
      """	text-decoration: none;""", //
      """}""", //
      """nav.atoolbar  li a:hover {""", //
      """	background-color: #8cae47;""", //
      """}"""
    ].join("\r\n"); //
    html.document.head.append(styleElement);
    var a = [];
    a.addAll([
      """<nav class="atoolbar">""", //
      """		<ul id="plain-menu">""",
    ]); //

    for (int i = 0; i < titles.length; i++) {
      a.addAll([
        """				<li><a href="#/${Uri.encodeComponent(hashs[i])}">${titles[i]}</a></li>""", //
      ]);
    }
    a.addAll([
      """		</ul>""", //
      """</nav>"""
    ]);

    html.document.body.appendHtml(a.join("\r\n")); //
  }
}
