import 'dart:async';
import './requester.dart';
import 'dart:convert' as conv;
import 'dart:html' as html;
import 'netbox.dart';

class NetBoxArtManager {
  String backendAddr;
  String apiKey;
  String version;
  String passwordKey;

  NetBoxArtManager(this.backendAddr, this.apiKey, {this.version: "v1", this.passwordKey: "umiuni2d"}) {}

  String makeUrlFromBlobKey(String blobKey) {
    return "${this.backendAddr}/api/v1/file/get?blobKey=${blobKey}";
  }

  Future<Map<String, String>> post(String userName, String loginId, String articleId, String title, String tab, String cont, String state) async {
    print("--");
    TinyNetHtml5Builder builder = new TinyNetHtml5Builder();
    TinyNetRequester requester = await builder.createRequester();
    String url = "${this.backendAddr}/api/v1/article/post";

    TinyNetRequesterResponse response = await requester.request(TinyNetRequester.TYPE_POST, url, //
        data: conv.JSON.encode({
          NetBox.ReqPropertyTab: tab,//
          NetBox.ReqPropertyTitle: title, //
          NetBox.ReqPropertyCont: cont, //
          NetBox.ReqPropertyArticleState: state, //
          NetBox.ReqPropertyName: userName,//
          NetBox.ReqPropertyArticleId: articleId, //
          NetBox.ReqPropertyLoginId: loginId,//
          NetBox.ReqPropertyRequestID: "AABBCC", //
          NetBox.ReqPropertyApiKey: apiKey
        }));
    //print(">> ${conv.UTF8.decode(response.response.asUint8List())}");
    return conv.JSON.decode(conv.UTF8.decode(response.response.asUint8List()));
  }
}
