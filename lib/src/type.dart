import 'internal.dart';

DartType createType(String k, dynamic v, String superName, List<String> names) {
  if (v is List) {
    if (v.isEmpty) {
      return DartType('List<dynamic>', 'dynamic', Type.ARRAY, k, v);
    } else {
      var type = toType(v);
      if (isPrimitive(type)) {
        return DartType('List<$type>', type, Type.ARRAY, k, v);
      }
      return DartType(
          'List<${upperCamelCase(k, superName, names)}>', upperCamelCase(k, superName, names), Type.ARRAY, k, v);
    }
  } else if (isPrimitive(toType(v))) {
    return DartType(toType(v), toType(v), Type.COMMON, k, v);
  } else {
    return DartType(upperCamelCase(k, superName, names), upperCamelCase(k, superName, names), Type.OBJECT, k, v);
  }
}

class DartType {
  final String name;
  final String className;
  final Type type;
  final String key;
  final dynamic value;

  DartType(this.name, this.className, this.type, this.key, this.value);
}

/// JSON TYPE
enum Type { COMMON, ARRAY, OBJECT }
