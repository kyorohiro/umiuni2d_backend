
import "dart:io" as io;
import "package:csv/csv.dart" as csv;
import "dart:convert" as convert;

void main(List<String> args) {
  print(">>>> ${args}");
  io.File f = new io.File("${args[0]}");
  var v = f.readAsBytesSync();

  csv.CsvCodec c = new csv.CsvCodec(fieldDelimiter: ",");
  var w = c.decode(convert.UTF8.decode(v));
  print(w);
}
