import 'dart:html' as html;
import 'dart:async';
import 'package:umiuni2d_backend_client/nbox.dart' as nbox;
import 'package:umiuni2d_backend_client/util.dart' as util;

class HomePage {
  String rootId;
  nbox.MyStatus status;
  nbox.NetBox netbox;

  HomePage(this.status, this.netbox, this.rootId) {
    html.window.onHashChange.listen((_) {
      updateFromHash();
    });
  }

  Future updateFromHash() async {
    var hash = util.Location.address(html.window.location.hash);
    var prop = util.Location.prop(html.window.location.hash);
    if (hash.startsWith("#/Home")) {
      print("--> HOME <--");
    }
  }

  update() {
    //

  }
}
