library hetima_netbox;

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';

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
}

//
//
//

class HtmlBuilder {}

abstract class TinyNetBuilder {
  Future<TinyNetRequester> createRequester();
}

abstract class TinyNetRequester {
  static final String TYPE_POST = "POST";
  static final String TYPE_GET = "GET";
  static final String TYPE_PUT = "PUT";
  static final String TYPE_DELETE = "DELETE";
  Future<TinyNetRequesterResponse> request(String type, String url, {Object data: null, Map<String, String> headers: null});
}

class TinyNetRequesterResponse {
  int _status;
  int get status => _status;
  ByteBuffer _response;
  ByteBuffer get response => (_response == null ? new Uint8List.fromList([]) : _response);
  Map<String, String> _headers = {};
  Map<String, String> get headers => _headers;
  TinyNetRequesterResponse(this._status, Map<String, String> headers, this._response) {
    _headers.addAll(headers);
  }
}

//
//
class TinyPercentEncode {
  static final Map<String, int> DECODE_TABLE = {"0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "a": 10, "A": 10, "b": 11, "B": 11, "c": 12, "C": 12, "d": 13, "D": 13, "e": 14, "E": 14, "f": 15, "F": 15};

  static final Map<int, String> ENCODE_TABLE = {0: "0", 1: "1", 2: "2", 3: "3", 4: "4", 5: "5", 6: "6", 7: "7", 8: "8", 9: "9", 10: "A", 11: "B", 12: "C", 13: "D", 14: "E", 15: "F"};

  static TinyPercentEncode _sencoder = new TinyPercentEncode();
  static List<int> decode(String message) {
    return _sencoder.decodeWork(message);
  }

  static String encode(List<int> target) {
    return _sencoder.encodeWork(target);
  }

  List<int> decodeWork(String message) {
    List<int> ret = [];
    List<int> target = UTF8.encode(message);
    int count = target.length;
    for (int i = 0; i < count; i++) {
      if (message[i] == '%') {
        int f = 0xFF & DECODE_TABLE[message[++i]];
        int e = 0xFF & DECODE_TABLE[message[++i]];
        int r = (f << 4) | e;
        ret.add(r);
      } else {
        ret.addAll(UTF8.encode(message[i]));
      }
    }
    return new Uint8List.fromList(ret);
  }

  String encodeWork(List<int> target) {
    List<int> ret = [];
    int count = target.length;
    for (int i = 0; i < count; i++) {
      if (45 == target[i] || 46 == target[i] || (48 <= target[i] && target[i] <= 57) || (65 <= target[i] && target[i] <= 90) || target[i] == 95 || (97 <= target[i] && target[i] <= 122) || target[i] == 126) {
        ret.add(target[i]);
      } else {
        int f = ((0xf0 & target[i]) >> 4);
        int e = ((0x0f & target[i]));
        ret.addAll(UTF8.encode("%" + ENCODE_TABLE[f] + ENCODE_TABLE[e]));
      }
    }
    return UTF8.decode(ret);
  }
}
