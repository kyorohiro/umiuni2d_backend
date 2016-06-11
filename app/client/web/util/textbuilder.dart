class TextBuilderTicket {
  List v = [];
}

class TextBuilder {
  TextBuilderTicket _root;
  TextBuilder() {
    _root = new TextBuilderTicket();
  }

  TextBuilderTicket getRootTicket() {
    return _root;
  }

  String toText(String lineEnd) {
    List<String> o = [];
    while (_root.v.length > 0) {
      var v = _root.v.removeAt(0);
      if (v is TextBuilderTicket) {
        _root.v.insertAll(0, v.v);
      } else {
        o.addAll(v);
      }
    }
    return o.join(lineEnd);
  }

  TextBuilderTicket pat(TextBuilderTicket obj, List<String> begin, List<String> end) {
    obj.v.add(begin);
    var child = [];
    obj.v.add(child);
    obj.v.add(end);
    return new TextBuilderTicket()..v = child;
  }

  head(TextBuilderTicket obj, List<String> v) {
    if (obj.v.length == 0) {
      obj.v.add(v);
    } else {
      obj.v.insert(0, v);
    }
  }

  end(TextBuilderTicket obj, List<String> v) {
    obj.v.add(v);
  }
}
