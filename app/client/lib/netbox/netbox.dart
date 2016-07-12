import 'netboxme.dart';
import 'netboxfile.dart';
import 'netboxart.dart';
import 'netboxfeed.dart';

class TwitterButton {
  String makeUrl(String comment, String address, String user) {
    return [
      """<a href="https://twitter.com/share" """, //
      """class="twitter-share-button" data-url="${address}" """, //
      """data-text="${comment}" data-via="${user}" data-size="large" data-dnt="true">Tweet</a>""", //
      """<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],""", //
      """p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id))""", //
      """{js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';""", //
      """fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>""", //
    ].join();
  }
}

class NetBoxBasicUsage {
  static Map<int, String> errorMessageEn = {NetBox.ReqPropertyCodeLocalWrongOpPassword: "Failed to this act, password and opt password is different.", NetBox.ReqPropertyCodeAlreadyExist: "Failed to this act, Already Exist", NetBox.ReqPropertyCodeWrongNamePass: "Failed to this act, Worng ID or Wrong Password", NetBox.ReqPropertyCodeNotFound: "Failed to this act, Not Found", NetBox.ReqPropertyCodeError: "Failed to this act, Server Error. Please Retry after long interval"};

  static String errorMessage(int v) {
    if (errorMessageEn.containsKey(v)) {
      return errorMessageEn[v];
    } else {
      return "";
    }
  }
}

class NetBox {
  static final String ReqPropertyName = "userName";
  static final String ReqPropertyTitle = "title";
  static final String ReqPropertyTag = "tag";
  static final String ReqPropertyCont = "cont";
  static final String ReqPropertyComments = "comment";
  static final String ReqPropertyArticleState = "state";
  static final String ReqPropertyArticleInfo = "info";
  static final String ReqPropertyParentID = "parentId";
  static final String ReqPropertyHaveContent = "haveContent";
  static final String ReqPropertyFileName = "fileName";
  static final String ReqPropertyPass = "password";
  static final String ReqPropertyNewPass = "newpassword";
  static final String ReqPropertyMail = "mail";
  static final String ReqPropertyRequestID = "requestId";
  static final String ReqPropertyApiKey = "apiKey";
  static final String ReqPropertyCode = "code";
  static final String ReqPropertyCursor = "cursor";
  static final String ReqPropertyCursorNext = "cursor_next";
  static final String ReqPropertyLoginId = "loginId";
  static final String ReqPropertyArticleId = "articleId";
  static final String ReqPropertyBlobKey = "blobKey";
  static final String ReqPropertyArticles = "arts";
  static final String ReqPropertyUsers = "users";
  static final String ReqPropertyUpdated = "updated";
  static final String ReqPropertyCreated = "created";
  static final int ReqPropertyCodeOK = 200;
  static final int ReqPropertyCodeLocalWrongOpPassword = 192001;
  static final int ReqPropertyCodeAlreadyExist = 1000;
  static final int ReqPropertyStateWrongNamePassID = -1;
  static final int ReqPropertyCodeError = 2000;
  static final int ReqPropertyCodeNotFound = 1001;
  static final int ReqPropertyCodeWrongNamePass = 1002;
  static final int ReqPropertyCodeWrongID = 1003;

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

  NetBoxArtManager newArtManager() {
    return new NetBoxArtManager(this.backendAddr, this.apiKey, version: this.version);
  }

  NetBoxFeed newNewOrderFeed() {
    return new NetBoxFeed(this.backendAddr, this.apiKey, version: this.version);
  }

  NetBoxFeedManager newNewOrderFeedManager() {
    return new NetBoxFeedManager(this.backendAddr, this.apiKey, version: this.version);
  }
}
