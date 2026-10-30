import 'dart:convert' show json;

import 'create_dart_class.dart';
import 'internal.dart';
import 'type.dart';

part 'json_parse.dart';

/// Returns the Dart source of a model class generated from [jsonString].
///
/// [name] is the base name of the generated class, usually the JSON file name.
/// Nested objects and arrays generate additional classes in the same source.
String parse(String name, String jsonString) {
  var param = Args();
  _parseJson(name, jsonString, param);
  return param.content.toString();
}
