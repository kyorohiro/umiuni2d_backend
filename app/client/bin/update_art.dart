
import "dart:io" as io;
import "package:csv/csv.dart" as csv;
import "dart:convert" as convert;
import 'package:umiuni2d_backend_client/nbox.dart' as nbox;
import 'package:umiuni2d_backend_client/netboxdartio.dart' as nbox;
void main(List<String> args) {
  print(">>>> ${args}");
  io.File f = new io.File("${args[0]}");
  var v = f.readAsBytesSync();
  //
  // login from twitter
  nbox.NetBox rootBox = new nbox.NetBox(//
    new nbox.TinyNetDartIoBuilder(), "http://127.0.0.1:8080", "A91A3E1B-15F0-4DEE-8ECE-F5DD1A06230E");

  io.HttpServer.bind("0.0.0.0", 8086).then((io.HttpServer server) {
    server.listen((io.HttpRequest request) {
      print(request.uri.path);
      print(request.uri.queryParameters);
    });
    
    rootBox.newMeManager().loginWithTwitter("http://127.0.0.1:8086").then(//
      (nbox.NetBoxMeManagerLoginTwitter res){
        print("## ${res.code} ${res.url}");
    //    runBrowser("${res.url}");
    });
  });
  //
  //
  //csv.CsvCodec c = new csv.CsvCodec(fieldDelimiter: ",");
  //var w = c.decode(convert.UTF8.decode(v));
  //print(w);
}

void runBrowser(String url) {
  var fail = false;
  switch (io.Platform.operatingSystem) {
    case "linux":
      io.Process.run("x-www-browser", [url]);
      break;
    case "macos":
      io.Process.run("open", [url]);
      break;
    case "windows":
      io.Process.run("explorer", [url]);
      break;
    default:
      fail = true;
      break;
  }

  if (!fail) {
    print("Start browsing...");
  }
}
