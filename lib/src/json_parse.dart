part of 'json_model.dart';

void _parseJson(String name, dynamic jsonElement, Args param) {
  var result = jsonElement;
  if (param.content.isEmpty) {
    // first invoke, parse json stirng
    name = genClassName(name);
    result = json.decode(jsonElement);
  }
  if (result is List) {
    _parseArray(name, result, Type.array, param);
  } else if (result is Map) {
    _parseObject(name, result, Type.object, param);
  }
}

void _parseArray(String name, List array, Type type, Args param) {
  var map = <String, dynamic>{};
  array
      .where((element) => element != null && element is Map)
      .map((e) => e as Map<String, dynamic>)
      .expand((element) => element.entries)
      .forEach((element) {
    if (map.containsKey(element.key)) {
      if (map[element.key] == null && element.value != null) {
        map[element.key] = element.value;
      }
    } else {
      map[element.key] = element.value;
    }
  });
  _parseObject(name, map, type, param, array: map.isEmpty ? array : []);
}

void _parseObject(String name, Map result, Type type, Args param, {List array = const []}) {
  var fieldNames = <DartType>[];
  var attrs = StringBuffer();
  var usedFieldNames = <String>{};
  result.forEach((key, value) {
    // 不同 key 可能转换出相同字段名（如 user-name 与 userName），重名时追加序号
    var baseName = toFieldName(key);
    var fieldName = baseName;
    for (var i = 2; !usedFieldNames.add(fieldName); i++) {
      fieldName = '$baseName$i';
    }
    var type = createType(key, value, name, param.names, fieldName);
    fieldNames.add(type);
    if (type.name == "dynamic") {
      attrs.write('${''.padLeft(2)}${'final ${type.name} $fieldName;\n'}');
    } else {
      attrs.write('${''.padLeft(2)}${'final ${type.name}? $fieldName;\n'}');
    }
  });
  var import = '';
  var decoder = '';
  var object = name;
  if (result.isEmpty) {
    object = toType(array);
  }
  if (param.content.isEmpty) {
    import = "import 'dart:convert' show json;";
    if (type == Type.array) {
      if (result.isNotEmpty) {
        decoder = '''
        \rList<$name> ${name.lowerLetterCase()}FromJson(String str) => List<$name>.from(json.decode(str).map((x) => $name.fromJson(x)));
        \rString ${name.lowerLetterCase()}ToJson(List<$name> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
      ''';
      } else {
        decoder = '''
        \rList<$object> ${name.lowerLetterCase()}FromJson(String str) => List<$object>.from(json.decode(str).map((x) => x));
        \rString ${name.lowerLetterCase()}ToJson(List<$object> data) => json.encode(List<dynamic>.from(data.map((x) => x)));
      ''';
      }
    } else if (type == Type.object) {
      decoder = '''
        \r$name ${name.lowerLetterCase()}FromJson(String str) => $name.fromJson(json.decode(str));
        \rString ${name.lowerLetterCase()}ToJson($name data) => json.encode(data.toJson());
      ''';
    }
  }
  var clazz = createDartClass(
      import: import,
      decoder: decoder,
      className: result.isNotEmpty ? name : '',
      fieldNames: fieldNames,
      attrs: attrs.toString());
  param.content.write(clazz);
  fieldNames.where((element) => element.type != Type.common).forEach((element) {
    if (!isPrimitive(element.className)) {
      var className = upperCamelCase(element.key, name, param.names);
      _parseJson(className, element.value, param);
      param.names.add(className);
    }
  });
}
