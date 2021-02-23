import 'dart:convert' show json;

import 'create_dart_class.dart';
import 'internal.dart';
import 'type.dart';

part 'json_parse.dart';

String parse(String name, String jsonString) {
  var param = Args();
  _parseJson(name, jsonString, param);
  return param.content.toString();
}
