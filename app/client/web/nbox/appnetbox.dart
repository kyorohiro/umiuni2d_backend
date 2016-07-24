import 'package:umiuni2d_backend_client/nbox.dart' as nbox;
import 'package:umiuni2d_backend_client/netboxhtml5.dart' as nbox;
import "package:csv/csv.dart" as csv;
import "dart:convert" as conv;
import "dart:async";

class AppNetBox {
  nbox.MyStatus status;
  nbox.NetBox netbox;

  AppNetBox(this.status, this.netbox) {
    ;
  }


  Future<List<List>> getIndex() async{
    nbox.TinyNetRequester req = await netbox.getBuilder().createRequester();
    nbox.TinyNetRequesterResponse res = await req.request("POST", netbox.getBackendAddr() + "/targets/index_jp.csv");
    //
    csv.CsvCodec cod = new csv.CsvCodec(fieldDelimiter: ",",eol: "\n");
    List<List> vs = cod.decode(conv.UTF8.decode(res.response.asUint8List()));
    return vs;
  }

  Future<List<String>> getTargetName() async{
    List<List<String>> vs = await getIndex();
    print("### ${vs}");
    List<String> chh = [];
    for (List<String> v in vs) {
      print(">>>> ${v}");
      chh.add(v[1]);
    }
    return chh;
  }
}
