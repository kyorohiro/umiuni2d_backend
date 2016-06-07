import 'dart:html' as html;
import 'dart:async';
import '../netbox/netbox.dart' as netboxm;
import '../netbox/status.dart' as netboxs;

class MePage {
  String rootId;
  netboxs.MyStatus status;
  netboxm.NetBox netbox;
  static String propUserName = "userName";
  static String propPassword = "password";

  MePage(this.status, this.netbox, this.rootId) {
    init();
    html.window.onHashChange.listen((_) {
      updateFromHash();
    });
  }

  Future updateFromHash() async {
    if (this.status.isLogin == false) {
      return;
    }
    String hash = html.window.location.hash;
    Map prop = {};
    if (hash.indexOf("?") > 0) {
      prop = Uri.splitQueryString(hash.substring(hash.indexOf("?") + 1));
      hash = hash.substring(0, hash.indexOf("?"));
    }
    if (hash.startsWith("#/Me")) {
      if (hash == "#/Me") {
        update();
      }
    }
  }

  init() {
    html.StyleElement styleElement = new html.StyleElement();
    styleElement.type = "text/css";
    styleElement.text = [
      """nav.mepage  {""", //
      """	background-color: #222222;""", //
      """	color: white;""", //
      """}""", //
      """nav.mepage ul {""", //
      //  """	display: flex;""", //
      """	flex-flow: row;""", //
      """	margin: 0;""", //
      """	padding: 6px;""", //
      """	list-style-type: none;""", //
      """}""", //
      """nav.mepage a {""", //
      """	display: block;""", //
      """	border-radius: 4px;""", //
      """	padding: 12px 24px;""", //
      """	color: white;""", //
      """	text-decoration: none;""", //
      """}""", //
      """nav.mepage li a:hover {""", //
      """	background-color: #8cae47;""", //
      """}"""
    ].join("\r\n"); //
    html.document.head.append(styleElement);
  }

  update() {
    html.Element elm = html.document.body.querySelector("#${this.rootId}");
    elm.children.clear();
    if (this.status.isLogin) {
      elm.appendHtml([
        """<H3>${this.status.userName}</H3>""",
        """<nav class="mepage">""", //
        """ <ul>""",
        """		<li>xxx</li>""", //
        """ </ul>""",
        """</nav>""",
      ].join());
    }
  }
}
