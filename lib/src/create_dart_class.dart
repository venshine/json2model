import 'type.dart';

String _fromJson(String className, List<DartType> fieldNames) => """
factory $className.fromJson(Map<String, dynamic> json) => $className(
    ${fieldNames.map((e) {
      var v = "";
      var json = "json['${e.keyLiteral}']";
      switch (e.type) {
        case Type.ARRAY:
          switch (e.className) {
            case "double":
              // json 中的 1 会被解码为 int，需要转换成 double
              v = "$json == null ? null : List<double>.from($json.map((x) => (x as num).toDouble()))";
              break;
            case "int":
            case "bool":
            case "String":
            case "dynamic":
              v = "$json == null ? null : List<${e.className}>.from($json.map((x) => x))";
              break;
            default:
              v = "$json == null ? null : List<${e.className}>.from($json.map((x) => ${e.className}.fromJson(x)))";
              break;
          }
          break;
        case Type.OBJECT:
          v = "$json == null ? null : ${e.className}.fromJson($json)";
          break;
        case Type.COMMON:
          // json 中的 1 会被解码为 int，需要转换成 double
          v = e.className == "double" ? "($json as num?)?.toDouble()" : json;
          break;
      }
      return '${e.fieldName}: $v';
    }).join(',\n\t\t')}
  );
  """;

String _toJson(List<DartType> fieldNames) => """
Map<String, dynamic> toJson() => {
    ${fieldNames.map((e) {
      var v = "";
      var field = e.fieldName;
      switch (e.type) {
        case Type.ARRAY:
          switch (e.className) {
            case "int":
            case "double":
            case "bool":
            case "String":
            case "dynamic":
              v = "$field == null ? null : List<dynamic>.from($field!.map((x) => x))";
              break;
            default:
              v = "$field == null ? null : List<dynamic>.from($field!.map((x) => x.toJson()))";
              break;
          }
          break;
        case Type.OBJECT:
          v = "$field == null ? null : $field?.toJson()";
          break;
        case Type.COMMON:
          v = field;
          break;
      }
      return "'${e.keyLiteral}': $v";
    }).join(',\n\t\t')}
  };
""";

String createDartClass({String import = "", String decoder = "", String className = "", String attrs = "", List<DartType> fieldNames = const []}) {
  var classOut = """
$import
$decoder
""";
  var classIn = """
class $className {
  $className({
    ${fieldNames.map((e) => 'this.${e.fieldName}').join(',\n\t\t')}
  });
  \r$attrs
  ${_fromJson(className, fieldNames)}
  ${_toJson(fieldNames)}
}
    """;
  return classOut + (className.isNotEmpty ? classIn : '');
}
