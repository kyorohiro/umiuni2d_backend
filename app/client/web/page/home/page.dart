import 'dart:html' as html;
import 'dart:async';
import 'package:umiuni2d_backend_client/nbox.dart' as nbox;
import 'package:umiuni2d_backend_client/util.dart' as util;

class HomePage {
  String rootId;
  nbox.MyStatus status;
  nbox.NetBox netbox;
  String applicationName;

  HomePage(this.status, this.netbox, this.rootId,{
    this.applicationName: "FoodFighter"
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
  }
}
