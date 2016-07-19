
import 'package:cookie/cookie.dart' as cookie;

class MyStatus {

  static final String keyObjectId = "user-objectId";
  static final String keyName = "user-name";

  static MyStatus _instance = new MyStatus();
  static MyStatus get instance => _instance;

  Map<String, String> binary = {};

  String get userObjectId => getFromKey(keyObjectId);
  String get userName => getFromKey(keyName);
  bool get isLogin => (userObjectId != null && userObjectId.length != 0);
  bool isMaster = false;

  void init() {

  }

  String getFromKey(String key) {
    if (binary.containsKey(key)) {
      return binary[key];
    }
    return cookie.get(key);
  }

  void set userName(String v) {
    if(v == null) {
      v = "";
    }
    binary[keyName] = v;
    cookie.set(keyName, v);
  }

  void set userObjectId(String v) {
    if(v == null) {
      v = "";
    }
    binary[keyObjectId] = v;
    cookie.set(keyObjectId, v);
  }
}
