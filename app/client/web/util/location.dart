class Location {


  static String address(String hash) {
    return hash.substring(0, hash.indexOf("?"));;
  }

  static Map<String,String> prop(String hash) {
    Map<String,String> prop = {};
    if (hash.indexOf("?") > 0) {
      prop = Uri.splitQueryString(hash.substring(hash.indexOf("?") + 1));
    }
    return prop;
  }
}
