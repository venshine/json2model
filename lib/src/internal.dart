String upperCamelCase(String name, String superName, List<String> names) {
  if (KEYWORDS.map((e) => e.toLowerCase()).contains(name.toLowerCase())) {
    return '${name.upperLetterCase()}Element';
  }
  if (names.map((e) => e.toLowerCase()).contains(name.toLowerCase())) {
    return '${superName.upperLetterCase()}${name.upperLetterCase()}';
  }
  return _filterName(name);
}

/// generate class name, lowercase first letter
String genClassName(String name) {
  var suffix = '';
  if (KEYWORDS.map((e) => e.toLowerCase()).contains(name.toLowerCase())) {
    suffix = 'Bean';
  }
  return '${_filterName(name)}$suffix';
}

/// filter special character, capitalize the first letter
String _filterName(String name) =>
    name
        .split(RegExp(r'\W'))
        .where((element) => element.isNotEmpty)
        .map((it) => '${it[0].toUpperCase()}${it.substring(1)}')
        .join();

/// convert json key to a valid dart field name, e.g. user-name -> userName, 1st -> n1st, class -> class_
String toFieldName(String key) {
  var parts = key.split(RegExp(r'[^A-Za-z0-9_$]')).where((element) => element.isNotEmpty).toList();
  // 命名参数不能以下划线开头，去掉前导下划线
  var name = parts.isEmpty ? '' : parts.first.replaceFirst(RegExp(r'^_+'), '');
  name += parts.skip(1).map((it) => it.upperLetterCase()).join();
  if (name.isEmpty) {
    name = 'field';
  }
  if (RegExp(r'^[0-9]').hasMatch(name)) {
    name = 'n$name';
  }
  if (KEYWORDS.contains(name)) {
    name = '${name}_';
  }
  return name;
}

/// escape json key for a single-quoted dart string literal
String escapeKey(String key) => key.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll(r'$', r'\$');

// ignore: camel_case_extensions
extension letterCase on String {
  // Lowercase first letter
  String lowerLetterCase() =>
      length == 1 ? toLowerCase() : this[0].toLowerCase() + substring(1);

  // Uppercase first letter
  String upperLetterCase() =>
      length == 1 ? toUpperCase() : this[0].toUpperCase() + substring(1);
}

const KEYWORDS = [
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'Function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'library',
  'mixin',
  'new',
  'null',
  'on',
  'operator',
  'part',
  'rethrow',
  'return',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'while',
  'with',
  'yield',
  'int',
  'double',
  'num',
  'bool',
  'String',
  'Map',
  'List',
  'Set'
];

/// Middle Arguments
class Args {
  final StringBuffer content = StringBuffer(); // json str
  final List<String> names = []; // class name
}

String toType(dynamic data) {
  if (data is List) {
    if (data.isEmpty) {
      return 'dynamic';
    }
    dynamic type = '';
    for (var e in data) {
      if (type.isNotEmpty && type != e.runtimeType.toString()) {
        return 'dynamic';
      }
      type = e.runtimeType.toString();
    }
    return toType(data[0]);
  } else if (data is int) {
    return 'int';
  } else if (data is double) {
    return 'double';
  } else if (data is bool) {
    return 'bool';
  } else if (data is String) {
    return 'String';
  } else if (data is Map) {
    return 'Map';
  } else {
    return 'dynamic';
  }
}

bool isPrimitive(String type) =>
    type == 'int' ||
    type == 'double' ||
    type == 'bool' ||
    type == 'String' ||
    type == 'dynamic';
