//
import './page/me/stlogin.dart';
import './page/me/stlogout.dart';
import './page/feed/feed.dart';
import './page/home/home.dart';
import './page/post/post.dart';
import 'config.dart';
import 'package:umiuni2d_backend_client/toolbar.dart';
import 'package:umiuni2d_backend_client/nbox.dart' as netbox;
import 'package:umiuni2d_backend_client/util.dart' as util;

//import 'dart:html' as aahtml;
Toolbar baseLine = new Toolbar();
netbox.NetBox rootBox = new netbox.NetBox("http://127.0.0.1:8080", "A91A3E1B-15F0-4DEE-8ECE-F5DD1A06230E");
//netbox.NetBox rootBox = new netbox.NetBox("http://liquid-champion-127202.appspot.com", "A91A3E1B-15F0-4DEE-8ECE-F5DD1A06230E");

//
//
void main() {
  baseLine.init();
  baseLine.updateToolbar(["Home", "Com", "Art", "Me"], ["Home", "Article?${netbox.NetBox.ReqPropertyArticleSubTag}=comment", "Article?${netbox.NetBox.ReqPropertyArticleSubTag}=art", "Me"]);
  MePage myPage = new MePage(netbox.MyStatus.instance, rootBox, "main");
  myPage.updateFromHash();
  MePageLogout myPageLogout = new MePageLogout(netbox.MyStatus.instance, rootBox, "main");
  myPageLogout.updateFromHash();

  initFeedStyleElment("feedNaviId");
  FeedPage feedPage = new FeedPage(netbox.MyStatus.instance, rootBox, "main", rootBox.newNewOrderFeedManager(), naviId: "feedNaviId");
  feedPage.updateFromHash();

  HomePage homePage = new HomePage(netbox.MyStatus.instance, rootBox, "main", applicationName: CONFIG_APPLICATION_NAME, naviId: "feedNaviId");
  homePage.updateFromHash();

  PostPage postPage = new PostPage(netbox.MyStatus.instance, rootBox, "main", rootBox.newNewOrderFeedManager(), naviId: "feedNaviId");
  postPage.updateFromHash();

  if (netbox.MyStatus.instance.isLogin) {
    rootBox.newMeManager().getMyInfo(netbox.MyStatus.instance.userObjectId).then((netbox.NetBoxMeManagerGetInfo v) {
      if (v.code != netbox.NetBox.ReqPropertyCodeOK) {
        netbox.MyStatus.instance.userObjectId = "";
        netbox.MyStatus.instance.userName = "";
        netbox.MyStatus.instance.isMaster = false;
      } else {
        print(">>>>>>>>>>>>>>>getinfo ${v.isMaster}");
        netbox.MyStatus.instance.isMaster = v.isMaster;
      }
    });
  }
}

initFeedStyleElment(String naviId) {
  var o = [
    """nav.${naviId}  {""", //
    """	background-color: #222222;""", //
    """	color: white;""", //
    """}""", //
    """nav.${naviId}  ul {""", //
    """	display: flex;""", //
    //"""	flex-flow: row;""", //
    """flex-wrap: wrap;""",
    """	margin: 2px;""", //
    """	padding: 6px;""", //
    """	list-style-type: none;""", //
    """}""", //
    """nav.${naviId} a {""", //
    """	display: block;""", //
    """	border-radius: 4px;""", //
    """	padding: 12px 24px;""", //
    """	color: white;""", //
    """	text-decoration: none;""", //
    """}""", //
    """nav.${naviId} li a {""", //
    """	margin: 2px;""", //
    """	background-color: #444444;""", //
    """}""",
    """nav.${naviId} li a:hover {""", //
    """	background-color: #8cae47;""", //
    """}""",
    """nav.${naviId} input.text {""", //
    """	display: flex;""", //
    """	flex-flow: row;""", //
    """ width:90%;""",
    """	margin: 0;""", //
    """	padding: 6px;""", //
    """	list-style-type: none;""", //
    """}""",
    """nav.${naviId} textarea.textarea {""", //
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
    """nav.${naviId} div.title {""", //
    """	display: inline-flex;""", //
    """	flex-flow: row;""", //
    """ width:90%;""",
    """	margin: 0;""", //
    """	padding: 6px;""", //
    """	list-style-type: none;""", //
    """}""",
    """nav.${naviId} button {""", //
    """	display: inline-flex;""", //
    """	border-radius: 4px;""", //
    """	padding: 6px 12px;""", //
//      """	color: white;""", //
    """	text-decoration: none;""", //
    """}""",
  ];
  util.Config.baseInst.addStyle(naviId, o.join("\r\n"));
}
