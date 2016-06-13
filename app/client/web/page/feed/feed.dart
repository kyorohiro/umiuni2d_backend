import 'dart:html' as html;
import 'dart:async';
import '../../netbox/netbox.dart' as nbox;
import '../../netbox/netboxme.dart' as nbox;
import '../../netbox/netboxfile.dart' as nbox;
import '../../netbox/netboxart.dart' as nbox;
import '../../netbox/status.dart' as nbox;
import '../../dialog/dialog_post.dart' as dialog;
import '../../util/textbuilder.dart' as util;

class FeedPage {
  String rootId;
  String naviId;
  String iconId;
  nbox.MyStatus status;
  nbox.NetBox netbox;

  FeedPage(this.status, this.netbox, this.rootId, {this.naviId: "aanaviId", this.iconId: "aaiconId"}) {
    html.window.onHashChange.listen((_) {
      updateFromHash();
    });
    init();
  }

  Future updateFromHash() async {
    if (this.status.isLogin == false) {
      return;
    }
    String hash = html.window.location.hash;
// prop = {};
    if (hash.indexOf("?") > 0) {
//      prop = Uri.splitQueryString(hash.substring(hash.indexOf("?") + 1));
      hash = hash.substring(0, hash.indexOf("?"));
    }
    if (hash.startsWith("#/Article")) {
      if (hash == "#/Article") {
        update();
      }
      if (hash == "#/Article/post") {
        //.update();
        dialog.PostDialog d = new dialog.PostDialog(status, netbox, width: "100%");
        d.init();
        d.show("", "title", [], "message<br>asdff<br>asdf<br>asasdf<br><br><br><br><br><br>asdafsdf", "private");
      }
    }
  }

  update() async {
    //
    html.Element elm = html.document.body.querySelector("#${this.rootId}");
    nbox.NetBoxArtManagerFind ret = await netbox.newArtManager().findArticleWithNewOrde("");
    util.TextBuilder builder = new util.TextBuilder();
    elm.children.clear();
    builder.end(builder.getRootTicket(), ["""<H2>Article</H2>""",]);

    var ticket = builder.pat(builder.getRootTicket(), [
      """<nav class="${this.naviId}">""", //
      """		<ul id="plain-menu">""",],[
      """		</ul>""",
      """</nav> """,
    ]);
    int w = 250;
    if(w > html.window.innerWidth) {
      w = html.window.innerWidth;
    }
    for (var v in ret.arts) {
      builder.end(ticket, [
        """    <li><a href="#/Article/get?${nbox.NetBox.ReqPropertyArticleId}=${v.articleId}"><div style="width:${w}px;">""",
        """      <table><tr><td> """,
        """       <img id="${this.iconId}" style="width:50px;display:inline; background-color:#99cc00;" src="${netbox.newMeManager().makeImgUserIconSrc(v.userName)}">""", //
        """      </td><td>""", ////
        """       <div style="font-size:15px"> ${v.title} """,
        """         <div style="font-size:10px"> ${v.userName} ${v.updated}</div>""",
        """       </div><br>""",
        """      </td></tr></table>""",
        """      <div style="font-size:10px"> ${v.tag} </div>""",
        """      <div style="font-size:8px">${v.articleInfo}</div>""",
        """      </div></a></li>""",]);
    }


    elm.appendHtml(builder.toText("\r\n"), treeSanitizer: html.NodeTreeSanitizer.trusted);
    //
    //
    if (this.status.isLogin) {
      //target="_blank"
      elm.appendHtml(["""<a href="#/Article/post" id="view-source">""", """Post</a>"""].join("\r\n"));
    }
  }

  init() {
    html.StyleElement styleElement = new html.StyleElement();
    styleElement.type = "text/css";
    var o = [
      """nav.${this.naviId}  {""", //
      """	background-color: #222222;""", //
      """	color: white;""", //
      """}""", //
      """nav.${this.naviId}  ul {""", //
      """	display: flex;""", //
      //"""	flex-flow: row;""", //
      """flex-wrap: wrap;""",
      """	margin: 2px;""", //
      """	padding: 6px;""", //
      """	list-style-type: none;""", //
      """}""", //
      """nav.${this.naviId} a {""", //
      """	display: block;""", //
      """	border-radius: 4px;""", //
      """	padding: 12px 24px;""", //
      """	color: white;""", //
      """	text-decoration: none;""", //
      """}""", //
      """nav.${this.naviId} li a {""", //
      """	margin: 2px;""", //
      """	background-color: #444444;""", //
      """}""",
      """nav.${this.naviId} li a:hover {""", //
      """	background-color: #8cae47;""", //
      """}""",
      """nav.${this.naviId} input.text {""", //
      """	display: flex;""", //
      """	flex-flow: row;""", //
      """ width:90%;""",
      """	margin: 0;""", //
      """	padding: 6px;""", //
      """	list-style-type: none;""", //
      """}""",
      """nav.${this.naviId} textarea.textarea {""", //
      """	display: inline-flex;""", //
      """	flex-flow: row;""", //
      """ width:90%;""",
      """ height:800px;""",
      """	margin: 0;""", //
      """	padding: 6px;""", //
      """	list-style-type: none;""", //
      """ text-align: left;""",
      """ vertical-align: top;""",
      """}""",
      """nav.${this.naviId} div.title {""", //
      """	display: inline-flex;""", //
      """	flex-flow: row;""", //
      """ width:90%;""",
      """	margin: 0;""", //
      """	padding: 6px;""", //
      """	list-style-type: none;""", //
      """}""",
      """nav.${this.naviId} button {""", //
      """	display: inline-flex;""", //
      """	border-radius: 4px;""", //
      """	padding: 6px 12px;""", //
//      """	color: white;""", //
      """	text-decoration: none;""", //
      """}""",
    ];
    styleElement.text = o.join("\r\n"); //
    html.document.head.append(styleElement);
  }
}
