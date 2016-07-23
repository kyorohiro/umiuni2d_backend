import 'requester.dart';
import 'dart:async';
import 'dart:html' as html;
import 'dart:convert' as conv;

class TinyNetHtml5Builder extends TinyNetBuilder {
  Future<TinyNetRequester> createRequester() async {
    return new TinyNetHtml5HttpRequester();
  }


}

class TinyNetHtml5HttpRequester extends TinyNetRequester {
  Future<TinyNetRequesterResponse> request(String type, String url, {Object data: null, Map<String, String> headers: null}) {
    if (headers == null) {
      headers = {};
    }
    Completer<TinyNetRequesterResponse> c = new Completer();
    try {
      html.HttpRequest req = new html.HttpRequest();
      req.responseType = "arraybuffer";
      req.open(type, url, async: true);
      for (String k in headers.keys) {
        req.setRequestHeader(k, headers[k]);
      }

      req.onReadyStateChange.listen((html.ProgressEvent e) {
        if (req.readyState == html.HttpRequest.DONE) {
          print("----> asdfasdf A ${req.response} :: ${req.statusText}");
          c.complete(new TinyNetRequesterResponse(req.status, req.responseHeaders, req.response));
        }
      });
      req.onError.listen((html.ProgressEvent e) {
        print("----> asdfasdf B ${e} :: ${req.statusText}");
        c.completeError(e);
      });
      if (data == null) {
        req.send();
      } else {
        req.send(data);
      }
    } catch (e) {
      c.completeError(e);
    }
    return c.future;
  }

  Future<Object> srcToMultipartData(String src) {
    List<int> v1 = conv.BASE64.decode(src);
    html.Blob b = new html.Blob([v1], "image/png");
    var fd = new html.FormData();
    fd.appendBlob("file", b);
    return fd;
  }
}
