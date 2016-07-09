//
import './page/me/stlogin.dart';
import './page/me/stlogout.dart';
import './page/feed/feed.dart';
import 'package:umiuni2d_backend_client/toolbar.dart';

import 'package:umiuni2d_backend_client/nbox.dart' as netbox;

//import 'dart:html' as aahtml;
Toolbar baseLine = new Toolbar();
netbox.NetBox rootBox = new netbox.NetBox("http://127.0.0.1:8080", "A91A3E1B-15F0-4DEE-8ECE-F5DD1A06230E");

//
//
void main() {
  baseLine.init();
  baseLine.updateToolbar(["Home", "Article", "Me"], ["Home", "Article", "Me"]);
  MePage myPage = new MePage(netbox.MyStatus.instance, rootBox, "main");
  myPage.updateFromHash();
  MePageLogout myPageLogout = new MePageLogout(netbox.MyStatus.instance, rootBox, "main");
  myPageLogout.updateFromHash();
  FeedPage feedPage = new FeedPage(netbox.MyStatus.instance, rootBox, "main", rootBox.newNewOrderFeedManager());
  feedPage.updateFromHash();
}
