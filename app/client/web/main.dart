//
import './page/me/stlogin.dart';
import './page/me/stlogout.dart';
import './page/feed/feed.dart';
import './toolbar/toolbar.dart';

import 'netbox/netbox.dart' as netbox;
import 'netbox/status.dart' as netbox;

import 'dart:html' as aahtml;
Toolbar baseLine = new Toolbar();
netbox.NetBox rootBox = new netbox.NetBox("http://127.0.0.1:8080", "A91A3E1B-15F0-4DEE-8ECE-F5DD1A06230E");

//
//
void main() {
  baseLine.init();
  baseLine.updateToolbar(["Article", "Q/A", "Vote", "Me"],
   ["Article", "Q/A", "Vote", "Me"]);
  aahtml.window.onHashChange.listen((_) {
    var hash = Uri.decodeComponent(aahtml.window.location.hash);
    for (var v in ["Article", "Q/A", "Vote"]) {
      if (hash == "#/${v}") {
        aahtml.Element elm = aahtml.document.body.querySelector("#main");
        elm.children.clear();
      }
    }
  });
  MePage myPage = new MePage(netbox.MyStatus.instance, rootBox, "main");
  myPage.updateFromHash();
  MePageLogout myPageLogout = new MePageLogout(netbox.MyStatus.instance, rootBox, "main");
  myPageLogout.updateFromHash();

  FeedPage feedPage = new FeedPage(netbox.MyStatus.instance, rootBox, "main");
  feedPage.updateFromHash();
  //

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
