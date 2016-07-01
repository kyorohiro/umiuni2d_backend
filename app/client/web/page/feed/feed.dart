import 'dart:html' as html;
import 'dart:async';
import '../../netbox/netbox.dart' as nbox;
import '../../netbox/netboxme.dart' as nbox;
import '../../netbox/netboxfile.dart' as nbox;
import '../../netbox/netboxart.dart' as nbox;
import '../../netbox/netboxfeed.dart' as nbox;
import '../../netbox/status.dart' as nbox;
import '../../dialog/dialog_post.dart' as dialog;
import '../../dialog/dialog_art.dart' as dialog;
import '../../util/textbuilder.dart' as util;
import '../../util/location.dart' as util;

class FeedPage {
  String rootId;
  String naviId;
  String iconId;
  String feedContainerId;
  String nextBtnId;
  nbox.MyStatus status;
  nbox.NetBox netbox;
  nbox.NetBoxFeedManager feederManager;
  nbox.NetBoxFeed feeder;
  dialog.PostDialog postDialog;
  dialog.ArtDialog artDialog;

  FeedPage(this.status, this.netbox, this.rootId, this.feederManager, //
      {this.naviId: "aanaviId",
      this.iconId: "aaiconId", //
      this.feedContainerId: "feedContainer",
      this.nextBtnId: "nextBtnId"}) {
    html.window.onHashChange.listen((_) {
      updateFromHash();
    });
    init();
    postDialog = new dialog.PostDialog(status, netbox, width: "100%");
    postDialog.init();
    artDialog = new dialog.ArtDialog(status, netbox, width: "90%");
    artDialog.init();
  }

  Future updateFromHash() async {
    var hash = util.Location.address(html.window.location.hash);
    var prop = util.Location.prop(html.window.location.hash);
    if (hash.startsWith("#/Article")) {
      bool usePostDialog = false;
      bool useArtDialog = false;

      if (hash == "#/Article/post") {
        postDialog.show("", "title", [], "post", "private");
        usePostDialog = true;
      }

      if (hash == "#/Article/get") {
        if (prop[nbox.NetBox.ReqPropertyArticleId] != null) {
          String articleId = prop[nbox.NetBox.ReqPropertyArticleId];
          nbox.NetBoxArtManagerFindArt art = await netbox.newArtManager().getArticleFromArticleId(articleId);
          artDialog.show(articleId, art.title, art.tag, art.cont, art.state);
          useArtDialog = true;
        }
      }

      if(usePostDialog == false ){
        try {
          postDialog.close();
        } catch (e) {}
      }
      if(useArtDialog == false){
        try {
          artDialog.close();
        } catch (e) {}
      }
      if (usePostDialog == false && usePostDialog == false ) {
        update(prop["tag"]);
      }
    }
  }

  nextFeed({isInit: false}) async {
    html.Element elm = html.document.body.querySelector("#${this.rootId}");
    html.Element cont = elm.querySelector("#${this.feedContainerId}");

    List<nbox.NetBoxArtManagerFindArt> ret = await feeder.next(); //await netbox.newArtManager().findArticleWithNewOrde("");

    int w = 250;
    if (w > html.window.innerWidth) {
      w = html.window.innerWidth;
    }

    for (var v in (isInit == true ? feeder.founded : ret)) {
      var e = new html.Element.html(
          [
            """    <li><a href="#/Article/get?${nbox.NetBox.ReqPropertyArticleId}=${Uri.encodeComponent(v.articleId)}"><div style="width:${w}px;">""",
            """      <table><tr><td> """,
            """       <img id="${this.iconId}" style="width:50px;display:inline; background-color:#99cc00;" src="${netbox.newMeManager().makeImgUserIconSrc(v.userName)}">""", //
            """      </td><td>""", ////
            """       <div style="font-size:15px"> ${v.title} """,
            """         <div style="font-size:10px"> ${v.userName} ${v.updated}</div>""",
            """       </div><br>""",
            """      </td></tr></table>""",
            """      <div style="font-size:10px"> ${v.tag} </div>""",
            """      <div style="font-size:8px">${v.articleInfo}</div>""",
            """      </div></a></li>""",
          ].join(),
          treeSanitizer: html.NodeTreeSanitizer.trusted);
      cont.children.add(e);
    }
  }

  update(String tag) async {
    print(">>>>>>> ${tag}");
    if(tag == null || tag == "") {
      feeder = feederManager.getNewOrder();
    } else {
      feeder = feederManager.getFromTag(tag);
    }
    //
    html.Element elm = html.document.body.querySelector("#${this.rootId}");
    util.TextBuilder builder = new util.TextBuilder();
    elm.children.clear();
    builder.end(builder.getRootTicket(), ["""<H2>Article</H2>""",]);

    var ticket = builder.pat(builder.getRootTicket(), [
      """<nav class="${this.naviId}">""", //
      """		<ul id="${this.feedContainerId}">""",
      """		</ul>""",
    ], [
      """</nav> """,
    ]);
    int w = 250;
    if (w > html.window.innerWidth) {
      w = html.window.innerWidth;
    }
    builder.end(ticket, [
      """    <ul><li><a id="${this.nextBtnId}"><div style="width:${w}px;">""",
      """      <table><tr><td> """,
//      """       <img id="${this.iconId}" style="width:50px;display:inline; background-color:#99cc00;" src="${netbox.newMeManager().makeImgUserIconSrc(v.userName)}">""", //
      """      </td><td>""", ////
      """       <div style="font-size:15px"> Next """,
      """         <div style="font-size:10px"> </div>""",
      """       </div><br>""",
      """      </td></tr></table>""",
      """      <div style="font-size:10px">  </div>""",
      """      <div style="font-size:8px"></div>""",
      """      </div></a></li></ul>""",
    ]);

    elm.appendHtml(builder.toText("\r\n"), treeSanitizer: html.NodeTreeSanitizer.trusted);
    nextFeed(isInit: true);
    //
    //
    if (this.status.isLogin) {
      //target="_blank"
      elm.appendHtml(["""<a href="#/Article/post" id="view-source">""", """Post</a>"""].join("\r\n"));
    }
    elm.querySelector("#${this.nextBtnId}").onClick.listen((_) {
      nextFeed(isInit: false);
    });
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
