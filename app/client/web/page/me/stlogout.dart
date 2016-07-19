import 'dart:html' as html;
import 'dart:async';
import 'dart:math' as math;
import 'package:umiuni2d_backend_client/nbox.dart' as nbox;
import 'package:umiuni2d_backend_client/util.dart' as util;
import 'package:umiuni2d_backend_client/dialog.dart' as dialog;

class MePageLogout {
  String rootId;
  nbox.MyStatus status;
  nbox.NetBox netbox;
  String propUserName = "userName";
  String propPassword = "password";
  String propPasswordOpt = "passwordOtp";
  bool useMeLogin = false;
  bool useTwitterLogin = false;

  MePageLogout(this.status, this.netbox, this.rootId, {this.useMeLogin: false, this.useTwitterLogin: true}) {
    init();
    html.window.onHashChange.listen((_) {
      updateFromHash();
    });
  }

  Future updateFromHash() async {
    if (this.status.isLogin == true) {
      return;
    }
    String hash = util.Location.address(html.window.location.hash);
    Map prop = util.Location.prop(html.window.location.hash);
    print("--ME LOGOUT->>>> ${hash}");
    if (hash.startsWith("#/Twitter")) {
      return;
    }
    if (hash.startsWith("#/Me")) {
      if (hash == "#/Me") {
        update();
      } else if (hash == "#/Me/register") {
        updateRegister(prop);
        if (prop.containsKey("code")) {
          showErrorDialog(prop);
        }
      } else if (hash == "#/Me/login") {
        updateLogin();
        if (prop.containsKey("code")) {
          showErrorDialog(prop);
        }
      } else if (hash == "#/Me/twitter") {
        print(">>> ");
        netbox.newMeManager().loginWithTwitter("${html.window.location.protocol}//${html.window.location.host}/#/Twitter").then((nbox.NetBoxMeManagerLoginTwitter v) {
          print(">>>> ${v.code} ${v.url}");
          html.window.location.assign(v.url);
        });
      }
    }
  }

  showErrorDialog(Map<String, String> prop) {
    if (prop.containsKey("code")) {
      dialog.ConfirmDialog d = new dialog.ConfirmDialog();
      d.init();
      try {
        d.show("Error", nbox.NetBoxBasicUsage.errorMessage(int.parse(prop["code"])), //
            onUpdated: (dialog.ConfirmDialog dd, bool okBtnIsSelected) async {
          return true;
        }, useCloseButton: false);
      } catch (e) {}
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
    util.TextBuilder builder = new util.TextBuilder();
    var item = builder.pat(builder.getRootTicket(), [
      """<H3>User</H3>""",
      """<nav class="mepage">""", //
      """ <ul>""",
    ], [
      """ </ul>""",
      """</nav>""",
    ]);
    if (this.useMeLogin == true) {
      builder.end(item, [
        """		<li><a href="#/Me/login">Login</a></li>""", //
        """		<li><a href="#/Me/register">Register</a></li>""", //
      ]);
    }
    if (this.useTwitterLogin == true) {
      builder.end(item, [
        """		<li><a href="#/Me/twitter" id="twitter_loginid">Twitter</a></li>""", //
      ]);
    }
    html.Element elm = html.document.body.querySelector("#${this.rootId}");
    elm.children.clear();
    elm.appendHtml(builder.toText("\r\n"));
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
      """   <li><input type="text" placeholder="User Name" id="${propUserName}"/></li>""",
      """   <li><input type="password" placeholder="Password" id="${propPassword}"/></li>""",
      """   <li><input type="password" placeholder="Rewrite password for confirm" id="${propPasswordOpt}"/></li>""",
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
      """   <li><input type="text"  placeholder="User Name" id="${propUserName}"/></li>""",
      """   <li><input type="password"  placeholder="Password" id="${propPassword}"/></li>""",
      """		<li><a href="#/Me/login/do">Login</a></li>""", //
      """ </ul>""",
      """</nav>""",
    ].join());
  }
}
