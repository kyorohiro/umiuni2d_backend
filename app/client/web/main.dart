//
import './page/me/stlogin.dart';
import './page/me/stlogout.dart';

import 'netbox/netbox.dart' as netbox;
import 'netbox/status.dart' as netbox;
import 'dart:html' as aahtml;
BaseLine baseLine = new BaseLine();
netbox.NetBox rootBox = new netbox.NetBox("http://127.0.0.1:8080", "A91A3E1B-15F0-4DEE-8ECE-F5DD1A06230E");

//
//
void main() {
  //
  baseLine.makeToolbar(//
      ["Home", "Article", "Q/A", "Vote", "Me"], ["Home", "Article", "Q/A", "Vote", "Me"]);
  baseLine.makeMain();

  aahtml.window.onHashChange.listen((_) {
    var hash = Uri.decodeComponent(aahtml.window.location.hash);
    for (var v in ["Home", "Article", "Q/A", "Vote"]) {
      if (hash == "#/${v}") {
        aahtml.Element elm = aahtml.document.body.querySelector("#main");
        elm.children.clear();
      }
    }
  });
  MePage myPage = new MePage(new netbox.MyStatus(), rootBox, "main");
  myPage.updateFromHash();
  MePageLogout myPageLogout = new MePageLogout(new netbox.MyStatus(), rootBox, "main");
  myPageLogout.updateFromHash();

  //

}

class BaseLine {
  makeMain() {
    aahtml.document.body.appendHtml([
      """<div id="main">""", //
      """</div>"""
    ].join("\r\n"));
  }

  makeToolbar(List<String> titles, List<String> hashs) {
    aahtml.StyleElement styleElement = new aahtml.StyleElement();
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
    aahtml.document.head.append(styleElement);
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

    aahtml.document.body.appendHtml(a.join("\r\n")); //
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
