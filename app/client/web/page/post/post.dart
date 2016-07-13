import 'dart:html' as html;
import 'dart:async';
import 'package:umiuni2d_backend_client/nbox.dart' as nbox;
import 'package:umiuni2d_backend_client/dialog.dart' as dialog;
import 'package:umiuni2d_backend_client/util.dart' as util;
import 'package:umiuni2d_backend_client/parts.dart' as parts;

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
  }

  Future updateFromHash() async {
    var hash = util.Location.address(html.window.location.hash);
    var prop = util.Location.prop(html.window.location.hash);
    if (hash.startsWith("#/Post")) {
      if(prop[nbox.NetBox.ReqPropertyArticleState] == nbox.NetBox.ReqPropertyArticles) {
        postDialog.show("", "title", [], "post", "private");
      } else if(prop[nbox.NetBox.ReqPropertyArticleState] == nbox.NetBox.ReqPropertyComments){
        targetDialog.show("Target Name", "Your comment target",onUpdated: (dialog.TextDialog d, String src){
          choiceDialog.show("Choice", "message", ["Greate", "Good", "Normal", "Bad", "SoBad"],onUpdated: (dialog.ChoiceDialog dialog, String choice){
            choiceDialog.close();
            postDialog.show("", "title", ["comment","${choice}","${src}"], "post", "private");
            return false;
          });
          targetDialog.close();
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
