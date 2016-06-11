import 'dart:html' as html;
import 'dart:async';
import '../../netbox/netbox.dart' as nbox;
import '../../netbox/netboxme.dart' as nbox;
import '../../netbox/netboxfile.dart' as nbox;
import '../../netbox/status.dart' as nbox;

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
    if (this.status.isLogin == false) {
      return;
    }
    String hash = html.window.location.hash;
// prop = {};
    if (hash.indexOf("?") > 0) {
//      prop = Uri.splitQueryString(hash.substring(hash.indexOf("?") + 1));
      hash = hash.substring(0, hash.indexOf("?"));
    }
  }

  update() {
    //

  }
}
