import 'requester.dart';
import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';

class TinyNetDartIoBuilder extends TinyNetBuilder {
  Future<TinyNetRequester> createRequester() async {
    return new TinyNetDartIoHttpRequester();
  }
}

class TinyNetDartIoHttpRequester extends TinyNetRequester {
  Future<TinyNetRequesterResponse> request(String type, String url, {Object data: null, Map<String, String> headers: null}) async {
    if (headers == null) {
      headers = {};
    }
    io.HttpClient cl = new io.HttpClient();
    //cl.
    io.HttpClientRequest req = null;
    if (type.toUpperCase() == TinyNetRequester.TYPE_POST) {
      req = await cl.postUrl(Uri.parse(url));
    } else if (type.toUpperCase() == TinyNetRequester.TYPE_GET) {
      req = await cl.getUrl(Uri.parse(url));
    } else if (type.toUpperCase() == TinyNetRequester.TYPE_PUT){
      req = await cl.putUrl(Uri.parse(url));
    } else if (type.toUpperCase() == TinyNetRequester.TYPE_DELETE){
      req = await cl.deleteUrl(Uri.parse(url));
    } else {
      throw new UnsupportedError("");
    }
    for (String k in headers.keys) {
      req.headers.set(k, headers[k]);
    }
    if (data != null) {
      if (data == ByteBuffer) {
        req.add((data as ByteBuffer).asUint8List());
      } else {
        req.write(data);
      }
    }
    io.HttpClientResponse res = await req.close();
    List<int> vv = [];
    await for(List<int> v in res) {
      vv.addAll(v);
    }
    Map<String,String> retHeader = {};
    res.headers.forEach((a,b){
      for(String v in b) {
      //  print("header=####=${a} ${v}");
        retHeader[a] = v;
      }
    });
    return new TinyNetRequesterResponse(res.statusCode, retHeader, new Uint8List.fromList(vv).buffer);
  }

  Future<String> srcToMultipartData(String src) async {
    return "";
  }
}
