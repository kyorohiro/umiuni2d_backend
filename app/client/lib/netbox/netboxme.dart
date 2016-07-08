import 'dart:async';
import './requester.dart';
import 'dart:convert' as conv;
import 'package:crypto/crypto.dart' as crypto;
import './netbox.dart';

class NetBoxMeManagerRegist {
  int code;
  String requestId;
  String loginId;

  NetBoxMeManagerRegist(TinyNetRequesterResponse response) {
    String body = conv.UTF8.decode(response.response.asUint8List());
    Map<String, Object> ret = conv.JSON.decode(body);
    this.code = ret[NetBox.ReqPropertyCode];
    this.requestId = ret[NetBox.ReqPropertyRequestID];
    this.loginId = ret[NetBox.ReqPropertyLoginId];
  }
}

class NetBoxMeManagerLogin {
  int code;
  String requestId;
  String loginId;

  NetBoxMeManagerLogin(TinyNetRequesterResponse response) {
    String body = conv.UTF8.decode(response.response.asUint8List());
    Map<String, Object> ret = conv.JSON.decode(body);
    this.code = ret[NetBox.ReqPropertyCode];
    this.requestId = ret[NetBox.ReqPropertyRequestID];
    this.loginId = ret[NetBox.ReqPropertyLoginId];
  }
}

class NetBoxMeManagerGetInfo {
  int code;
  String requestId;
  String name;
  String mail;

  NetBoxMeManagerGetInfo(TinyNetRequesterResponse response) {
    String body = conv.UTF8.decode(response.response.asUint8List());
    Map<String, Object> ret = conv.JSON.decode(body);
    this.code = ret[NetBox.ReqPropertyCode];
    this.requestId = ret[NetBox.ReqPropertyRequestID];
    this.name = ret[NetBox.ReqPropertyName];
    this.mail = ret[NetBox.ReqPropertyMail];
  }
}

class NetBoxMeManagerMail {
  int code;
  String requestId;

  NetBoxMeManagerMail(TinyNetRequesterResponse response) {
    String body = conv.UTF8.decode(response.response.asUint8List());
    Map<String, Object> ret = conv.JSON.decode(body);
    this.code = ret[NetBox.ReqPropertyCode];
    this.requestId = ret[NetBox.ReqPropertyRequestID];
  }
}

class NetBoxMeManagerLogout {
  int code;
  String requestId;

  NetBoxMeManagerLogout(TinyNetRequesterResponse response) {
    String body = conv.UTF8.decode(response.response.asUint8List());
    Map<String, Object> ret = conv.JSON.decode(body);
    this.code = ret[NetBox.ReqPropertyCode];
    this.requestId = ret[NetBox.ReqPropertyRequestID];
  }
}

class NetBoxMeManagerPassword {
  int code;
  String requestId;

  NetBoxMeManagerPassword(TinyNetRequesterResponse response) {
    String body = conv.UTF8.decode(response.response.asUint8List());
    Map<String, Object> ret = conv.JSON.decode(body);
    this.code = ret[NetBox.ReqPropertyCode];
    this.requestId = ret[NetBox.ReqPropertyRequestID];
  }
}

class NetBoxMeManager {
  String backendAddr;
  String apiKey;
  String version;
  String passwordKey;

  NetBoxMeManager(this.backendAddr, this.apiKey, {this.version: "v1", this.passwordKey: "umiuni2d"}) {}

  String makeImgUserIconSrc(String name) {
    return """${backendAddr}/api/v1/me_mana/get_icon?name=${name}""";
  }

  Future<NetBoxMeManagerRegist> regist(String name, String mail, String pass) async {
    TinyNetHtml5Builder builder = new TinyNetHtml5Builder();
    TinyNetRequester requester = await builder.createRequester();
    String url = "${backendAddr}/api/${version}/me_mana/regist_user";

    TinyNetRequesterResponse response = await requester.request(
        //
        TinyNetRequester.TYPE_POST,
        url, //
        data: conv.JSON.encode({
          NetBox.ReqPropertyName: name, //
          NetBox.ReqPropertyMail: mail, //
          NetBox.ReqPropertyPass: conv.BASE64.encode(//
              crypto.sha256.convert(conv.UTF8.encode(//
                  "" + name + ":" + passwordKey + ":" + pass)).bytes), //
          NetBox.ReqPropertyRequestID: "AABBCC", //
          NetBox.ReqPropertyApiKey: apiKey
        }));
    return new NetBoxMeManagerRegist(response);
  }

  Future<NetBoxMeManagerLogin> login(String name, String pass) async {
    TinyNetHtml5Builder builder = new TinyNetHtml5Builder();
    TinyNetRequester requester = await builder.createRequester();
    String url = "${backendAddr}/api/${version}/me_mana/login";

    TinyNetRequesterResponse response = await requester.request(
        //
        TinyNetRequester.TYPE_POST,
        url, //
        data: conv.JSON.encode({
          NetBox.ReqPropertyName: name, //
          NetBox.ReqPropertyPass: conv.BASE64.encode(//
              crypto.sha256.convert(conv.UTF8.encode(//
                  "" + name + ":" + passwordKey + ":" + pass)).bytes), //
          NetBox.ReqPropertyRequestID: "AABBCC", //
          NetBox.ReqPropertyApiKey: apiKey
        }));
    return new NetBoxMeManagerLogin(response);
  }

  Future<NetBoxMeManagerGetInfo> getMyInfo(String loginId) async {
    TinyNetHtml5Builder builder = new TinyNetHtml5Builder();
    TinyNetRequester requester = await builder.createRequester();
    String url = "${backendAddr}/api/${version}/me_mana/get_info";

    TinyNetRequesterResponse response = await requester.request(
        //
        TinyNetRequester.TYPE_POST,
        url, //
        data: conv.JSON.encode({
          NetBox.ReqPropertyLoginId: loginId, //
          NetBox.ReqPropertyRequestID: "AABBCC", //
          NetBox.ReqPropertyApiKey: apiKey
        }));
    return new NetBoxMeManagerGetInfo(response);
  }

  Future<NetBoxMeManagerMail> mail(String name, String mail, String pass, String loginId) async {
    TinyNetHtml5Builder builder = new TinyNetHtml5Builder();
    TinyNetRequester requester = await builder.createRequester();
    String url = "${backendAddr}/api/${version}/me_mana/update_mail";

    TinyNetRequesterResponse response = await requester.request(TinyNetRequester.TYPE_POST, url,
        data: conv.JSON.encode({
          NetBox.ReqPropertyMail: mail, //
          NetBox.ReqPropertyPass: conv.BASE64.encode(//
              crypto.sha256.convert(conv.UTF8.encode(//
                  "" + name + ":" + passwordKey + ":" + pass)).bytes), //
          NetBox.ReqPropertyRequestID: "AABBCC", //
          NetBox.ReqPropertyLoginId: loginId,
          NetBox.ReqPropertyApiKey: apiKey
        })); //
    return new NetBoxMeManagerMail(response);
  }

  Future<NetBoxMeManagerPassword> password(String userName, String newpass, String pass, String loginId) async {
    TinyNetHtml5Builder builder = new TinyNetHtml5Builder();
    TinyNetRequester requester = await builder.createRequester();
    String url = "${backendAddr}/api/${version}/me_mana/update_password";

    TinyNetRequesterResponse response = await requester.request(TinyNetRequester.TYPE_POST, url, //
        data: conv.JSON.encode({
          //
          NetBox.ReqPropertyNewPass: conv.BASE64.encode(//
              crypto.sha256.convert(conv.UTF8.encode(//
                  "" + userName + ":" + passwordKey + ":" + newpass)).bytes), //
          NetBox.ReqPropertyPass: conv.BASE64.encode(//
              crypto.sha256.convert(conv.UTF8.encode(//
                  "" + userName + ":" + passwordKey + ":" + pass)).bytes), //
          NetBox.ReqPropertyRequestID: "AABBCC", //
          NetBox.ReqPropertyLoginId: loginId, //
          NetBox.ReqPropertyApiKey: apiKey
        }));
    return new NetBoxMeManagerPassword(response);
  }

  Future<NetBoxMeManagerLogout> logout(String loginId) async {
    TinyNetHtml5Builder builder = new TinyNetHtml5Builder();
    TinyNetRequester requester = await builder.createRequester();
    String url = "${backendAddr}/api/${version}/me_mana/logout";

    TinyNetRequesterResponse response = await requester.request(TinyNetRequester.TYPE_POST, url, //
        data: conv.JSON.encode({
          NetBox.ReqPropertyLoginId: loginId, //
          NetBox.ReqPropertyRequestID: "AABBCC", //
          NetBox.ReqPropertyApiKey: apiKey
        }));
    return new NetBoxMeManagerLogout(response);
  }
/*
//






  Future<Map<String, String>> rescue(String mail) async {
    print("--");
    TinyNetHtml5Builder builder = new TinyNetHtml5Builder();
    TinyNetRequester requester = await builder.createRequester();
    String url = "${targetHost}/api/v1/me/rescue_from_mail";
    TinyNetRequesterResponse response = await requester.request(TinyNetRequester.TYPE_POST, url,
      headers: {"apikey": apiKey,}, data: conv.JSON.encode({"mail": mail, "reqId": "AABBCC"}));
    print(">> ${conv.UTF8.decode(response.response.asUint8List())}");
    return conv.JSON.decode(conv.UTF8.decode(response.response.asUint8List()));
  }


  */
}
