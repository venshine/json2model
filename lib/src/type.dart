import 'internal.dart';

DartType createType(String k, dynamic v, String superName, List<String> names, String fieldName) {
  if (v is List) {
    if (v.isEmpty) {
      return DartType('List<dynamic>', 'dynamic', Type.ARRAY, k, v, fieldName);
    } else {
      var type = toType(v);
      if (isPrimitive(type)) {
        return DartType('List<$type>', type, Type.ARRAY, k, v, fieldName);
      }
      return DartType('List<${upperCamelCase(k, superName, names)}>', upperCamelCase(k, superName, names),
          Type.ARRAY, k, v, fieldName);
    }
  } else if (isPrimitive(toType(v))) {
    return DartType(toType(v), toType(v), Type.COMMON, k, v, fieldName);
  } else {
    return DartType(
        upperCamelCase(k, superName, names), upperCamelCase(k, superName, names), Type.OBJECT, k, v, fieldName);
  }
}

class DartType {
  final String name;
  final String className;
  final Type type;
  final String key; // 原始 json key
  final dynamic value;
  final String fieldName; // 生成代码中的字段名，保证是合法的 dart 标识符

  DartType(this.name, this.className, this.type, this.key, this.value, this.fieldName);

  /// 可以直接放进单引号字符串字面量的 json key
  String get keyLiteral => escapeKey(key);
}

/// JSON TYPE
enum Type { COMMON, ARRAY, OBJECT }
