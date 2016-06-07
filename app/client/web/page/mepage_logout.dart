import 'dart:html' as html;
import 'dart:async';
import '../netbox/netbox.dart' as netboxm;
import '../netbox/status.dart' as netboxs;

class MePageLogout {
  String rootId;
  netboxs.MyStatus status;
  netboxm.NetBox netbox;
  static String propUserName = "userName";
  static String propPassword = "password";

  MePageLogout(this.status, this.netbox, this.rootId) {
    init();
    html.window.onHashChange.listen((_) {
      updateFromHash();
    });
  }

  Future updateFromHash() async {
    if (this.status.isLogin == true) {
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
      } else if (hash == "#/Me/register") {
        updateRegister(prop);
      } else if (hash == "#/Me/login") {
        updateLogin();
      } else if (hash == "#/Me/register/do") {
        html.Element elm = html.document.body.querySelector("#${this.rootId}");
        html.InputElement userNameElm = elm.querySelector("#${propUserName}");
        html.InputElement passwordElm = elm.querySelector("#${propPassword}");
        var r = await this.netbox.newMeManager().regist(userNameElm.value, "", passwordElm.value);
        if (r.code == 200) {
          this.status.userName = userNameElm.value;
          this.status.userObjectId = r.loginId;
          html.window.location.assign("#/Me");
        } else {
          html.window.location.assign("#/Me/register?code=${r.code}");
        }
      } else if (hash == "#/Me/login/do") {
        html.Element elm = html.document.body.querySelector("#${this.rootId}");
        html.InputElement userNameElm = elm.querySelector("#${propUserName}");
        html.InputElement passwordElm = elm.querySelector("#${propPassword}");
        var r = await this.netbox.newMeManager().login(userNameElm.value, passwordElm.value);
        if (r.code == 200) {
          this.status.userName = userNameElm.value;
          this.status.userObjectId = r.loginId;
          html.window.location.assign("#/Me");
        } else {
          html.window.location.assign("#/Me/login?code=${r.code}");
        }
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
    elm.appendHtml([
      """<H3>User</H3>""",
      """<nav class="mepage">""", //
      """ <ul>""",
      """		<li><a href="#/Me/login">Login</a></li>""", //
      """		<li><a href="#/Me/register">Register</a></li>""", //
      """ </ul>""",
      """</nav>""",
    ].join());
  }

  updateRegister(Map prop) {
    html.Element elm = html.document.body.querySelector("#${this.rootId}");
    elm.children.clear();
    elm.appendHtml([
      """<H3>User</H3>""",
      """<nav class="mepage">""", //
      """ <ul>""",
      """		<li>Register</li>""", //
      """   <li>${prop["code"] != null ?prop["code"]:""}</li>""",
      """   <li><input type="text" id="${propUserName}"/></li>""",
      """   <li><input type="password" id= "${propPassword}"/></li>""",
      """		<li><a href="#/Me/register/do">Regist</a></li>""", //
      """ </ul>""",
      """</nav>""",
    ].join());
  }

  updateLogin() {
    html.Element elm = html.document.body.querySelector("#${this.rootId}");
    elm.children.clear();
    elm.appendHtml([
      """<H3>User</H3>""",
      """<nav class="mepage">""", //
      """ <ul>""",
      """		<li>Login</li>""", //
      """   <li><input type="text" id="${propUserName}"/></li>""",
      """   <li><input type="text" id="${propPassword}"/></li>""",
      """		<li><a href="#/Me/login/do">Login</a></li>""", //
      """ </ul>""",
      """</nav>""",
    ].join());
  }
}
