import 'dart:html' as html;
import 'package:umiuni2d_backend_client/nbox.dart' as nbox;
import 'package:umiuni2d_backend_client/util.dart' as util;

class UserParts {
  String rootId;
  String subId;
  String iconId;
  nbox.NetBoxFeed feeder;
  nbox.NetBox netbox;
  String naviClassName;
  String nextBtnId;

  UserParts(this.rootId, this.subId, this.iconId, this.feeder, this.netbox, this.naviClassName, {String nextBtnId: "xxx"}) {}

  feed(String naviId) {
    html.Element elm = html.document.body.querySelector("#${rootId}");
    util.TextBuilder builder = new util.TextBuilder();

    //var ticket =
    builder.pat(builder.getRootTicket(), [
      """<nav class="${naviId}">""", //
      """		<ul id="${subId}">""",
      """		</ul>""",
    ], [
      """</nav> """,
    ]);

    elm.appendHtml(builder.toText("\r\n"), treeSanitizer: html.NodeTreeSanitizer.trusted);
  }

  next() {
    html.Element elm = html.document.body.querySelector("#${rootId}");
    html.Element cont = elm.querySelector("#${subId}");
    util.TextBuilder builder = new util.TextBuilder();
    var ticket = builder.pat(builder.getRootTicket(), [
      """<nav class="${naviClassName}">""", //
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
      """    <ul><li><a id="${nextBtnId}"><div style="width:${w}px;">""",
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
    elm.querySelector("#${nextBtnId}").onClick.listen((_) {
      nextFeed(isInit: false);
    });
  }

  nextFeed({isInit: false}) async {
    html.Element elm = html.document.body.querySelector("#${rootId}");
    html.Element cont = elm.querySelector("#${subId}");

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
            """       <img id="${iconId}" style="width:50px;display:inline; background-color:#99cc00;" src="${netbox.newMeManager().makeImgUserIconSrc(v.userName)}">""", //
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
}
