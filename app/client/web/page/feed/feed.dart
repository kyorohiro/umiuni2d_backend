import 'dart:html' as html;
import 'dart:async';
import 'package:umiuni2d_backend_client/nbox.dart' as nbox;
import 'package:umiuni2d_backend_client/dialog.dart' as dialog;
import 'package:umiuni2d_backend_client/util.dart' as util;
import 'package:umiuni2d_backend_client/parts.dart' as parts;

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
      {this.naviId: "feedNaviId",
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

      if (usePostDialog == false) {
        try {
          postDialog.close();
        } catch (e) {}
      }
      if (useArtDialog == false) {
        try {
          artDialog.close();
        } catch (e) {}
      }
      if (usePostDialog == false && usePostDialog == false) {
        update(prop["tag"]);
      }
    }
  }

  nextFeed({isInit: false}) async {
    parts.ArticleParts artParts = new parts.ArticleParts();
    artParts.nextFeed(this.rootId, this.feedContainerId, this.iconId, this.feeder, this.netbox,isInit: isInit);
  }

  update(String tag) async {
    print(">>>>>>> ${tag}");
    if (tag == null || tag == "") {
      feeder = feederManager.getNewOrder();
    } else {
      feeder = feederManager.getFromTag(tag);
    }
    //
    //
    html.Element elm = html.document.body.querySelector("#${this.rootId}");
    util.TextBuilder builder = new util.TextBuilder();
    elm.children.clear();
    elm.appendHtml(["""<H2>Article</H2>""",].join());

    parts.ArticleParts artParts = new parts.ArticleParts();
    artParts.feed(this.rootId, this.naviId, this.feedContainerId);

    var ticket = builder.pat(builder.getRootTicket(), [
      """<nav class="${this.naviId}">""", //
      """		<ul>""",
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

  init() {}
}
