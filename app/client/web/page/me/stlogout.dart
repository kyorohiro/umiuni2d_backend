import 'dart:html' as html;
import 'dart:async';
import 'package:umiuni2d_backend_client/nbox.dart'  as netboxm;
import '../../util/location.dart' as util;
import '../../dialog/dialog_confirm.dart' as dialog;

class MePageLogout {
  String rootId;
  netboxm.MyStatus status;
  netboxm.NetBox netbox;
  String propUserName = "userName";
  String propPassword = "password";
  String propPasswordOpt = "passwordOtp";

  MePageLogout(this.status, this.netbox, this.rootId) {
    init();
    html.window.onHashChange.listen((_) {
      updateFromHash();
    });
  }

  Future updateFromHash() async {
    print("##====> ${this.status.isLogin}");
    if (this.status.isLogin == true) {
      return;
    }
    String hash = util.Location.address(html.window.location.hash);
    Map prop = util.Location.prop(html.window.location.hash);
    print("--->>>> ${hash}");
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
      } else if (hash == "#/Me/register/do") {
        html.Element elm = html.document.body.querySelector("#${this.rootId}");
        html.InputElement userNameElm = elm.querySelector("#${propUserName}");
        html.InputElement passwordElm = elm.querySelector("#${propPassword}");
        html.InputElement passwordOptElm = elm.querySelector("#${propPasswordOpt}");
        if (passwordElm.value != passwordOptElm.value) {
          print(">> ${passwordElm.value} :: ${passwordOptElm.value}");
          html.window.location.assign("#/Me/register?code=${netboxm.NetBox.ReqPropertyCodeLocalWrongOpPassword}");
          return;
        }

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

  showErrorDialog(Map<String,String> prop) {
    if (prop.containsKey("code")) {
      dialog.ConfirmDialog d = new dialog.ConfirmDialog();
      d.init();
      try {
        d.show("Error", netboxm.NetBoxBasicUsage.errorMessage(int.parse(prop["code"])), //
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
