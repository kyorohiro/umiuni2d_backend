import 'dart:html' as html;
import 'dart:async';
import 'package:umiuni2d_backend_client/nbox.dart' as nbox;
import 'package:umiuni2d_backend_client/util.dart' as util;

class HomePage {
  String rootId;
  nbox.MyStatus status;
  nbox.NetBox netbox;
  String applicationName;
  String naviId;
  String aboutArticleId;

  HomePage(this.status, this.netbox, this.rootId,{
    this.applicationName: "FoodFighter",
    this.aboutArticleId:"AboutThisSite",
    this.naviId: "HomeContainer"
  }) {
    html.window.onHashChange.listen((_) {
      updateFromHash();
    });
  }

  Future updateFromHash() async {
    var hash = util.Location.address(html.window.location.hash);
    var prop = util.Location.prop(html.window.location.hash);
    if (hash.startsWith("#/Home")) {
      print("--> HOME <--");
      update();
    }
  }

  update() {
      html.Element elm = html.document.body.querySelector("#${this.rootId}");
      elm.children.clear();
      elm.appendHtml("""<H3>${applicationName}</H3>""");
//      html.Element cont = elm.querySelector("#${subId}");
      util.TextBuilder builder = new util.TextBuilder();
      var ticket = builder.pat(builder.getRootTicket(), [
        """<nav class="${naviId}">""", //
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
        """    <ul><li><a href="#/Article/get?${nbox.NetBox.ReqPropertyArticleId}=${Uri.encodeComponent(this.aboutArticleId)}"><div style="width:${w}px;">""",
        """      <table><tr><td> """,
  //      """       <img id="${this.iconId}" style="width:50px;display:inline; background-color:#99cc00;" src="${netbox.newMeManager().makeImgUserIconSrc(v.userName)}">""", //
        """      </td><td>""", ////
        """       <div style="font-size:15px"> About """,
        """         <div style="font-size:10px"> </div>""",
        """       </div><br>""",
        """      </td></tr></table>""",
        """      <div style="font-size:10px">  </div>""",
        """      <div style="font-size:8px"></div>""",
        """      </div></a></li></ul>""",
      ]);
      elm.appendHtml(builder.toText("\r\n"), treeSanitizer: html.NodeTreeSanitizer.trusted);
      a();
      if (this.status.isLogin) {
        html.Element button = new html.Element.html(["""<button id="view-source">""", """Post</button>"""].join("\r\n"));
        elm.children.add(button);
        button.onClick.listen((ev){
          print("---> btn");
          html.window.location.assign("#/Post/comment?tag=comment&${nbox.NetBox.ReqPropertyArticleState}=${nbox.NetBox.ReqPropertyComments}");

        });
      }
  }
  a() {
    html.Element elm = html.document.body.querySelector("#${this.rootId}");
    util.TextBuilder builder = new util.TextBuilder();
    var ticket = builder.pat(builder.getRootTicket(), [
      """<nav class="${naviId}">""", //
      """		<ul>""",
      """		</ul>""",
    ], [
      """</nav> """,
    ]);


    netbox.newMeManager().findUserWithNewOrder("").then((nbox.NetBoxMeFindUser f){
      print("### ---> ");
      for(nbox.NetBoxMeFindUserItem i in f.users) {
        print(">> ${i.userName}");
        //
        //nbox.NetBox.ReqPropertyName
        builder.end(ticket, [
          """    <ul><li><a href="#/Article?${nbox.NetBox.ReqPropertyName}=${Uri.encodeComponent(i.userName)}"><div style="width:${100}px;">""",
          """       <p style="text-align:center">""",
          """       <img style="width:80px;width:80px;display:inline; background-color:#99cc00;" src="${netbox.newMeManager().makeImgUserIconSrc(i.userName)}">""", //
          """       </p>""",
          //"""       <br>""",
          """       <div style="font-size:15px"> ${i.userName} """,
        //  """         <div style="font-size:10px"> </div>""",
          """       </div><br>""",
          """      <div style="font-size:10px">  </div>""",
          """      <div style="font-size:8px"></div>""",
          """      </div></a></li></ul>""",
        ]);
      }
      elm.appendHtml(builder.toText("\r\n"), treeSanitizer: html.NodeTreeSanitizer.trusted);
    });

  }
}
