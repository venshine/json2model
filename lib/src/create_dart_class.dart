import 'type.dart';

String _fromJson(String className, List<DartType> fieldNames) => """
factory $className.fromJson(Map<String, dynamic> json) => $className(
    ${fieldNames.map((e) {
      var v = "";
      switch (e.type) {
        case Type.ARRAY:
          switch (e.className) {
            case "int":
            case "double":
            case "bool":
            case "String":
            case "dynamic":
              v = "json['${e.key}'] == null ? null : List<${e.className}>.from(json['${e.key}'].map((x) => x))";
              break;
            default:
              v = "json['${e.key}'] == null ? null : List<${e.className}>.from(json['${e.key}'].map((x) => ${e.className}.fromJson(x)))";
              break;
          }
          break;
        case Type.OBJECT:
          v = "json['${e.key}'] == null ? null : ${e.className}.fromJson(json['${e.key}'])";
          break;
        case Type.COMMON:
        default:
          v = "json['${e.key}']";
          break;
      }
      return '${e.key}: $v';
    }).join(',\n\t\t')}
  );
  """;

String _toJson(List<DartType> fieldNames) => """
Map<String, dynamic> toJson() => {
    ${fieldNames.map((e) {
      var v = "";
      switch (e.type) {
        case Type.ARRAY:
          switch (e.className) {
            case "int":
            case "double":
            case "bool":
            case "String":
            case "dynamic":
              v = "${e.key} == null ? null : List<dynamic>.from(${e.key}.map((x) => x))";
              break;
            default:
              v = "${e.key} == null ? null : List<dynamic>.from(${e.key}.map((x) => x.toJson()))";
              break;
          }
          break;
        case Type.OBJECT:
          v = "${e.key} == null ? null : ${e.key}.toJson()";
          break;
        case Type.COMMON:
        default:
          v = e.key;
          break;
      }
      return "'${e.key}': $v";
    }).join(',\n\t\t')}
  };
""";

String createDartClass({String import, String decoder, String className, String attrs, List<DartType> fieldNames}) {
  var classOut = """
$import
$decoder
""";
  var classIn = """
class $className {
  $className({
    ${fieldNames.map((e) => 'this.${e.key}').join(',\n\t\t')}
  });
  \r$attrs
  ${_fromJson(className, fieldNames)}
  ${_toJson(fieldNames)}
}
    """;
  return classOut + (className.isNotEmpty ? classIn : '');
}
