import 'dart:html' as html;

class MePage {
  String rootId;
  MePage(this.rootId) {
    init();
    html.window.onHashChange.listen((_) {
      String hash = html.window.location.hash;
      if (hash.startsWith("#/Me")) {
        print("=Me=> ${html.window.location.hash} :");
        if (hash == "#/Me") {
          update();
        } else if (hash == "#/Me/register") {
          updateRegister();
        } else if (hash == "#/Me/login") {
          updateLogin();
        }
      }
    });
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

  updateRegister() {
    html.Element elm = html.document.body.querySelector("#${this.rootId}");
    elm.children.clear();
    elm.appendHtml([
      """<H3>User</H3>""",
      """<nav class="mepage">""", //
      """ <ul>""",
      """		<li>Register</li>""", //
      """   <li><input type="text"/></li>""",
      """   <li><input type="text"/></li>""",
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
      """   <li><input type="text"/></li>""",
      """   <li><input type="text"/></li>""",
      """		<li><a href="#/Me/login/do">Login</a></li>""", //
      """ </ul>""",
      """</nav>""",
    ].join());
  }
}
