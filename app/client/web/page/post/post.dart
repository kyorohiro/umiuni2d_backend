import 'dart:html' as html;
import 'dart:async';
import 'package:umiuni2d_backend_client/nbox.dart' as nbox;
import 'package:umiuni2d_backend_client/netboxhtml5.dart' as nbox;
import 'package:umiuni2d_backend_client/dialog.dart' as dialog;
import 'package:umiuni2d_backend_client/util.dart' as util;
import 'package:umiuni2d_backend_client/parts.dart' as parts;
import "package:csv/csv.dart" as csv;
import "dart:convert" as conv;

class PostPage {
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
  dialog.TextDialog targetDialog;
  dialog.ChoiceDialog choiceDialog1;
  dialog.ChoiceDialog choiceDialog;
  PostPage(this.status, this.netbox, this.rootId, this.feederManager, //
      {this.naviId: "feedNaviId",
      this.iconId: "aaiconId", //
      this.feedContainerId: "feedContainer",
      this.nextBtnId: "nextBtnId"}) {
    html.window.onHashChange.listen((_) {
      updateFromHash();
    });
    //
    postDialog = new dialog.PostDialog(status, netbox, width: "100%");
    postDialog.init();
    //
    targetDialog = new dialog.TextDialog();
    targetDialog.init();

    choiceDialog = new dialog.ChoiceDialog(status, netbox);
    choiceDialog.init();

    choiceDialog1 = new dialog.ChoiceDialog(status, netbox, dialogName: "dialogName");
    choiceDialog1.init();
  }

  Future updateFromHash() async {
    nbox.TinyNetRequester req = await netbox.getBuilder().createRequester();
    nbox.TinyNetRequesterResponse res = await req.request("POST", netbox.getBackendAddr() + "/targets/index_jp.csv");
    //
    csv.CsvCodec cod = new csv.CsvCodec(fieldDelimiter: ",",eol: "\n");
    List<List<String>> vs = cod.decode(conv.UTF8.decode(res.response.asUint8List()));
    print("### ${vs}");
    List<String> chh = [];
    for (List<String> v in vs) {
      print(">>>> ${v}");
      chh.add(v[1]);
    }
    //
    var hash = util.Location.address(html.window.location.hash);
    var prop = util.Location.prop(html.window.location.hash);
    if (hash.startsWith("#/Post")) {
      if (prop[nbox.NetBox.ReqPropertyArticleState] == nbox.NetBox.ReqPropertyArticles) {
        print("---##=--#---art");
        postDialog.show("", "title", [], "art", "", "post", "private");
      } else if (prop[nbox.NetBox.ReqPropertyArticleState] == nbox.NetBox.ReqPropertyComments) {
//        targetDialog.show("Target Name", "Your comment target",onUpdated: (dialog.TextDialog d, String src){
        choiceDialog.show("Choice", "message", chh, onUpdated: (dialog.ChoiceDialog dialog1, String choice1) {
          choiceDialog.close();
          new Future(() {
            choiceDialog.show("Choice", "message", ["Greate", "Good", "Normal", "Bad", "SoBad"], onUpdated: (dialog.ChoiceDialog dialog, String choice) {
              choiceDialog.close();
              postDialog.show("", "title", ["${choice}", "${choice1}"], "comment", "", "post", "private");
              return false;
            });
          });
          //targetDialog.close();
          return false;
//          postDialog.show("", "title", ["comment"], "post", "private");
        });
      }
    } else {
      try {
        postDialog.close();
      } catch (e) {}
    }
  }
}
