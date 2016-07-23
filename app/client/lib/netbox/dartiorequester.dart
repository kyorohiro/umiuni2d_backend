import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
//import 'package:'
import 'package:tetorica/net.dart' as tet;
import 'package:tetorica/http.dart' as tet;
import 'requester.dart';

class TinyNetTetoricaBuilder extends TinyNetBuilder {
  tet.TetSocketBuilder builder;
  TinyNetTetoricaBuilder(this.builder) {}

  Future<TinyNetRequester> createRequester() async {
    return new TinyNetTetoricaHttpRequester(builder);
  }
}

class TinyNetTetoricaHttpRequester extends TinyNetRequester {
  tet.TetSocketBuilder builder;
  TinyNetTetoricaHttpRequester(this.builder) {}

  Future<TinyNetRequesterResponse> request(String type, String url, {Object data: null, Map<String, String> headers: null}) async {
    if (headers == null) {
      headers = {};
    }
    tet.HttpClientHelper cl = new tet.HttpClientHelper(builder);

    tet.HttpClientResponse res = null;
    Uri uri = Uri.parse(url);
    List<int> dat = const [];
    if (data is List<int>) {
      dat = data;
    } else if (data is ByteBuffer) {
      dat = data.asUint8List();
    } else if (data is ByteData) {
      dat = data.buffer.asUint8List();
    } else if (data is String) {
      dat = UTF8.encode(data);
    }

    if (type.toUpperCase() == TinyNetRequester.TYPE_POST) {
      res = await cl.post(uri.host, uri.port, "${uri.path}?${uri.query}", dat, header: headers, useSecure: (uri.scheme == "https"));
    } else if (type.toUpperCase() == TinyNetRequester.TYPE_GET) {
      res = await cl.get(uri.host, uri.port, "${uri.path}?${uri.query}", header: headers, useSecure: (uri.scheme == "https"));
    } else if (type.toUpperCase() == TinyNetRequester.TYPE_PUT) {
      res = await cl.put(uri.host, uri.port, "${uri.path}?${uri.query}", dat, header: headers, useSecure: (uri.scheme == "https"));
    } else if (type.toUpperCase() == TinyNetRequester.TYPE_DELETE) {
      res = await cl.delete(uri.host, uri.port, "${uri.path}?${uri.query}", header: headers, useSecure: (uri.scheme == "https"));
    } else {
      throw new UnsupportedError("");
    }

    Map<String, String> retHeader = {};
    for (tet.HttpResponseHeaderField h in res.message.headerField) {
      retHeader[h.fieldName] = h.fieldValue;
    }
    Uint8List v = new Uint8List.fromList(await res.body.getAllBytes());
    return new TinyNetRequesterResponse(res.message.line.statusCode, retHeader, v.buffer);
  }

  Future<String> srcToMultipartData(String src) async {
    return "";
  }
}
/*import 'requester.dart';
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
*/
