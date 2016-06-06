import 'dart:html' as html;
import 'mepage.dart';

BaseLine baseLine = new BaseLine();
void main() {
  baseLine.makeToolbar(//
      ["Home", "Article", "Q/A", "Vote", "Me"], ["Home", "Article", "Q/A", "Vote", "Me"]);
  baseLine.makeMain();

  html.window.onHashChange.listen((_) {
    print("==> ${html.window.location.hash} :");
    var hash = Uri.decodeComponent(html.window.location.hash);
    for (var v in ["Home", "Article", "Q/A", "Vote"]) {
      if (hash == "#/${v}") {
        html.Element elm = html.document.body.querySelector("#main");
        elm.children.clear();
      }
    }
  });
  MePage myPage = new MePage("main");
}

class BaseLine {
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
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
/*
makeList() {
  html.StyleElement styleElement = new html.StyleElement();
  styleElement.type = "text/css";
  styleElement.text = [
    //
    """.mobile-menu-toggle {""", //
    """    left: -9999px;""", //
    """    position: absolute;""", //
    """    top: -9999px;""", //
    """}""", //
    """.mobmenu-toggle,""", //
    """.mobile-menu-toggle-button,""", //
    """.mobile-toggleable-menu {""", //
    """    top: 0;""", //
    """    position: fixed;""", //
//    """    -webkit-transition: all 0.2s;""",
//    """    -moz-transition: all 0.2s;""",
//    """    -ms-transition: all 0.2s;""",
//    """    -o-transition: all 0.2s;""",
    """    transition: all 0.2s;""", //
    """}""", //
    """.mobmenu-toggle {""", //
    """    left: 0;""", //
    """    margin: 0;""", //
    """    display: inline-block;""", //
    """    width: 15%;""", //
    """    z-index: 999;""", //
    """}""", //
    """.mobmenu-toggle:hover {""", //
    """    cursor: pointer;""", //
    """}""", //
    """.mobile-toggleable-menu {""", //
    """    margin: 0;""", //
    """    width: 85%;""", //
    """    height: 100%;""", //
    """    max-height: 100%;""", //
    """    min-height: 100%;""", //
    """    z-index: 998;""", //
    """    overflow: hidden;""", //
    """}""", //
    """.mobile-toggleable-menu.mobile-left {""", //
    """    left: -105%;""", //
    """}""", //
    """.mobile-toggleable-menu.mobile-right {""", //
    """    right: -105%;""", //
    """}""", //
    """.mobile-menu-toggle-button:checked + .mobile-toggleable-menu.mobile-left {""", //
    """    width: 85% !important;""", //
    """    left: 0;""", //
    """}""", //
    """.mobile-menu-toggle-button:checked + .mobile-toggleable-menu.mobile-right {""", //
    """    width: 85% !important;""", //
    """    right: 0;""", //
    """}""" //
  ].join("\r\n");
  html.document.head.append(styleElement);
  html.document.body.appendHtml([
    """<nav>""", //
    """		<input type="checkbox" id="mobile-menu-toggle" class="mobile-menu-toggle mobile-menu-toggle-button">""", //
    """		<ul id="plain-menu" class="mobile-toggleable-menu mobile-left">""", //
    """				<li><a href="#">Home</a></li>""", //
    """				<li><a href="#">About</a></li>""", //
    """				<li><a href="#">Contact</a></li>""", //
    """				<li><a href="#">Portfolio</a></li>""", //
    """		</ul>""", //
    """		<label class="mobile-left mobmenu-toggle" for="mobile-menu-toggle">+</label>""", //
    """</nav>"""
  ].join("\r\n"));
}
*/
