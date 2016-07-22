import 'dart:async';
import './requester.dart';
import 'dart:convert' as conv;
import 'dart:html' as html;
import 'netbox.dart';

class NetBoxFileShareManagerFileShare {
  int code;
  String requestId;
  String blobKey;

  NetBoxFileShareManagerFileShare(TinyNetRequesterResponse response) {
    String body = conv.UTF8.decode(response.response.asUint8List());
    Map<String, Object> ret = conv.JSON.decode(body);
    this.code = ret[NetBox.ReqPropertyCode];
    this.requestId = ret[NetBox.ReqPropertyRequestID];
    this.blobKey = ret[NetBox.ReqPropertyBlobKey];
  }
}

class NetBoxFileShareManager {
  String backendAddr;
  String apiKey;
  String version;
  String passwordKey;
  TinyNetBuilder builder;
  NetBoxFileShareManager(this.builder, this.backendAddr, this.apiKey, {this.version: "v1", this.passwordKey: "umiuni2d"}) {}

  String makeUrlFromBlobKey(String blobKey) {
     return "${this.backendAddr}/api/v1/file/get?blobKey=${blobKey}";
  }

  Future<NetBoxFileShareManagerFileShare> fileShare(String src, String articleId, String loginId) async {
    TinyNetRequester requester = await builder.createRequester();
    //
    // get request id
    String url = "${this.backendAddr}/api/v1/file/get_request_id";
    TinyNetRequesterResponse response = await requester.request(TinyNetRequester.TYPE_POST, url, //
        headers: {"apikey": apiKey,}, //
        data: conv.JSON.encode({
          NetBox.ReqPropertyLoginId: loginId, //
          NetBox.ReqPropertyArticleId: articleId, //
          NetBox.ReqPropertyRequestID: "AABBCC"
        }));
    Map<String, String> ret = await conv.JSON.decode(conv.UTF8.decode(response.response.asUint8List()));

    // todo
    String imageUrl = ret["url"];

    //
    //
    {
      List<int> v1 = conv.BASE64.decode(src.replaceFirst(new RegExp(".*,"), ''));
      html.Blob b = new html.Blob([v1], "image/png");
      var fd = new html.FormData();
      fd.appendBlob("file", b);

      TinyNetRequesterResponse response = await requester.request(TinyNetRequester.TYPE_POST, imageUrl, data: fd);

      return new NetBoxFileShareManagerFileShare(response);
    }
  }
}
