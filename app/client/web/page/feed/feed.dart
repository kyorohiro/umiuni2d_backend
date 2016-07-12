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
      //  postDialog.show("", "title", [], "post", "private");
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
          //postDialog.close();
        } catch (e) {}
      }
      if (useArtDialog == false) {
        try {
          artDialog.close();
        } catch (e) {}
      }
      if (usePostDialog == false && usePostDialog == false) {
        update(tag:prop[nbox.NetBox.ReqPropertyTag],userName: prop[nbox.NetBox.ReqPropertyName]);
      }
    }
  }

  update({String tag:"",String userName:""}) async {
    print(">>>>>>> ${tag}");
    if (userName == null || userName == "") {
      feeder = feederManager.getNewOrder(userName:userName);
    } else if (tag != null && tag == "") {
      feeder = feederManager.getFromTag(tag);
    } else {
      feeder = feederManager.getNewOrder();
    }
    //
    //
    html.Element elm = html.document.body.querySelector("#${this.rootId}");
    util.TextBuilder builder = new util.TextBuilder();
    elm.children.clear();
    elm.appendHtml(["""<H2>Article</H2>""",].join());

    parts.ArticleParts artParts = new parts.ArticleParts(
        //
        this.rootId,
        this.feedContainerId,
        this.iconId,
        this.feeder,
        this.netbox,
        //
        this.naviId,
        nextBtnId: this.nextBtnId);
    artParts.feed(this.naviId);
    artParts.next();
    artParts.nextFeed(isInit: true);
    //
    //
    if (this.status.isLogin) {
      //target="_blank"
      elm.appendHtml(["""<a href="#/Post/post" id="view-source">""", """Post</a>"""].join("\r\n"));
    }
  }

  init() {}
}
