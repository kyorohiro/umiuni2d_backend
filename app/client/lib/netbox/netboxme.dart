import 'dart:async';
import './requester.dart';
import 'dart:convert' as conv;
import 'package:crypto/crypto.dart' as crypto;
import './netbox.dart';
import 'requester.dart';

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

class NetBoxMeManagerLoginTwitter {
  int code;
  String requestId;
  String loginId;
  String url;

  NetBoxMeManagerLoginTwitter(TinyNetRequesterResponse response) {
    print("## ${response.response}");
    String body = conv.UTF8.decode(response.response.asUint8List());
    Map<String, Object> ret = conv.JSON.decode(body);
    this.code = ret[NetBox.ReqPropertyCode];
    this.requestId = ret[NetBox.ReqPropertyRequestID];
    this.loginId = ret[NetBox.ReqPropertyLoginId];
    this.url = ret[NetBox.ReqPropertyUrl];
  }
}

class NetBoxMeManagerGetInfo {
  int code;
  String requestId;
  String name;
  String mail;
  bool isMaster;

  NetBoxMeManagerGetInfo(TinyNetRequesterResponse response) {
    String body = conv.UTF8.decode(response.response.asUint8List());
    Map<String, Object> ret = conv.JSON.decode(body);
    this.code = ret[NetBox.ReqPropertyCode];
    this.requestId = ret[NetBox.ReqPropertyRequestID];
    this.name = ret[NetBox.ReqPropertyName];
    this.mail = ret[NetBox.ReqPropertyMail];
    this.isMaster = ret[NetBox.ReqPropertyIsMaster];
  }
}

class NetBoxMeFindUserItem {
  String userName;
  NetBoxMeFindUserItem.empty() {
  }
}

class NetBoxMeFindUser {
  int code;
  String requestId;
  String loginId;
  String cursorNext;
  List<NetBoxMeFindUserItem> users = [];
  NetBoxMeFindUser(TinyNetRequesterResponse response) {
    String body = conv.UTF8.decode(response.response.asUint8List());
    Map<String, Object> ret = conv.JSON.decode(body);
    this.code = ret[NetBox.ReqPropertyCode];
    this.requestId = ret[NetBox.ReqPropertyRequestID];
    this.loginId = ret[NetBox.ReqPropertyLoginId];
    this.cursorNext = ret[NetBox.ReqPropertyCursorNext];
    this.users = load(ret);
  }

  List<NetBoxMeFindUserItem> load(Map<String, Object> src) {
    List ret = [];
    Object o = src[NetBox.ReqPropertyUsers];
    if (o == null || !(o is List)) {
      print("----> (1) ${o}");
      return ret;
    }
    for (var v in (o as List)) {
      print("----> (2)");

      if (v == null || !(v is Map)) {
        continue;
      }
      //
      NetBoxMeFindUserItem a = new NetBoxMeFindUserItem.empty();
      a.userName = v[NetBox.ReqPropertyName];
      ret.add(a);
    }
    return ret;
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
  TinyNetBuilder builder;
  NetBoxMeManager(this.builder, this.backendAddr, this.apiKey, {this.version: "v1", this.passwordKey: "umiuni2d"}) {}

  String makeImgUserIconSrc(String name) {
    return """${backendAddr}/api/v1/me_mana/get_icon?name=${name}""";
  }

  Future<NetBoxMeManagerRegist> regist(String name, String mail, String pass) async {
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

// "${netbox.backendAddr}/api/v1/me_mana/login_from_twitter"
Future<NetBoxMeManagerLoginTwitter> loginWithTwitter(String callbackUrl) async {
  TinyNetRequester requester = await builder.createRequester();
  String url = "${backendAddr}/api/${version}/me_mana/login_from_twitter";

  TinyNetRequesterResponse response = await requester.request(
      //
      TinyNetRequester.TYPE_POST,
      url, //
      data: conv.JSON.encode({
        NetBox.ReqPropertyRequestID: "AABBCC", //
        NetBox.ReqPropertyApiKey: apiKey,
        NetBox.ReqPropertyUrl: callbackUrl,
      }));
  return new NetBoxMeManagerLoginTwitter(response);
}

  Future<NetBoxMeManagerLogin> login(String name, String pass) async {
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

  Future<NetBoxMeFindUser> findUserWithNewOrder(String cursor) async {
    TinyNetRequester requester = await builder.createRequester();
    String url = "${this.backendAddr}/api/${version}/me_mana/find_with_neworder";
    TinyNetRequesterResponse response = await requester.request(TinyNetRequester.TYPE_POST, url, //
        data: conv.JSON.encode({
          NetBox.ReqPropertyRequestID: "AABBCC", //
          NetBox.ReqPropertyApiKey: apiKey,
          NetBox.ReqPropertyCursor: cursor
        }));
    return new NetBoxMeFindUser(response);
  }
}
