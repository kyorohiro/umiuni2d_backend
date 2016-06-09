import 'netboxme.dart';
import 'netboxfile.dart';

class NetBox {
  static final String ReqPropertyName = "userName";
  static final String ReqPropertyFileName = "fileName";
  static final String ReqPropertyPass = "password";
  static final String ReqPropertyNewPass = "newpassword";
  static final String ReqPropertyMail = "mail";
  static final String ReqPropertyRequestID = "requestId";
  static final String ReqPropertyApiKey = "apiKey";
  static final String ReqPropertyCode = "code";
  static final String ReqPropertyCursor = "cursor";
  static final String ReqPropertyLoginId = "loginId";
  static final String ReqPropertyArticleId = "articleId";
  static final int ReqPropertyCodeOK = 200;
  static final int ReqPropertyCodeAlreadyExist = 1000;
  String backendAddr;
  String apiKey;
  String version;
  String passwordKey;

  NetBox(this.backendAddr, this.apiKey, {this.version: "v1", this.passwordKey: "umiuni2d"}) {}

  NetBoxMeManager newMeManager() {
    return new NetBoxMeManager(this.backendAddr, this.apiKey, version: this.version);
  }

  NetBoxFileShareManager newFileShareManager() {
    return new NetBoxFileShareManager(this.backendAddr, this.apiKey, version: this.version);
  }
}
