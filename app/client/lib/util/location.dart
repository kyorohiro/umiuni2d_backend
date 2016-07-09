class Location {
  static String address(String hash) {
    if (hash == null) {
      return "";
    }
    int index = hash.indexOf("?");
    if (index < 0) {
      return hash;
    }
    return hash.substring(0, index);
  }

  static Map<String, String> prop(String hash) {
    if (hash == null) {
      return {};
    }
    Map<String, String> prop = {};
    if (hash.indexOf("?") > 0) {
      prop = Uri.splitQueryString(hash.substring(hash.indexOf("?") + 1));
    }
    return prop;
  }
}
