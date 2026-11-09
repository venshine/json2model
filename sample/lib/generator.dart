import 'dart:convert' show JsonEncoder, json;

import 'package:dart_style/dart_style.dart';
import 'package:json2model/json2model.dart' show parse;

/// 一次生成的结果：成功时有代码；失败时 [errorCode] 和 [message] 说明原因
class GenerateResult {
  const GenerateResult._({
    this.code = '',
    this.errorCode,
    this.message,
    this.verified = false,
    this.classes = 0,
    this.fields = 0,
  });

  /// 展示给用户的代码：校验通过时是格式化后的代码，否则是库的原始输出
  final String code;

  /// 可区分的错误码，null 表示没有错误
  final String? errorCode;
  final String? message;

  /// 生成的代码能被 Dart 解析器完整解析（由 dart_style 格式化成功判定）
  final bool verified;
  final int classes;
  final int fields;

  bool get hasCode => code.isNotEmpty;
}

final _formatter = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);

/// 调用库的 [parse] 把 [input] 转成 Dart 模型代码，并用 Dart 解析器校验结果
GenerateResult generate(String className, String input) {
  if (input.trim().isEmpty) {
    return const GenerateResult._(errorCode: 'E_EMPTY', message: 'Paste or type some JSON to start.');
  }
  Object? decoded;
  try {
    decoded = json.decode(input);
  } on FormatException catch (e) {
    final at = e.offset == null ? '' : ' (offset ${e.offset})';
    return GenerateResult._(errorCode: 'E_JSON', message: 'Invalid JSON: ${e.message}$at');
  }
  if (decoded is! Map && decoded is! List) {
    return const GenerateResult._(errorCode: 'E_ROOT', message: 'The top-level value must be an object or an array.');
  }

  final name = className.trim().isEmpty ? 'model' : className.trim();
  final String raw;
  try {
    raw = parse(name, input);
  } catch (e) {
    return GenerateResult._(errorCode: 'E_GENERATE', message: 'json2model failed: $e');
  }

  // Dart 标识符可以含 $（如 json key "$ref" 生成的字段），\w 不够
  final classes = RegExp(r'^\s*class [\w$]+', multiLine: true).allMatches(raw).length;
  final fields = RegExp(r'^\s*final \S+ [\w$]+;', multiLine: true).allMatches(raw).length;
  try {
    return GenerateResult._(code: _formatter.format(raw), verified: true, classes: classes, fields: fields);
  } on FormatterException catch (e) {
    // 生成的代码不是合法 Dart：照原样展示，并给出解析器的报错
    return GenerateResult._(
      code: raw,
      errorCode: 'E_DART_SYNTAX',
      message: 'Generated code does not parse as Dart:\n${e.message()}',
      classes: classes,
      fields: fields,
    );
  }
}

/// 把 JSON 重新缩进成两个空格；输入不是合法 JSON 时返回 null
String? prettyJson(String input) {
  try {
    return const JsonEncoder.withIndent('  ').convert(json.decode(input));
  } on FormatException {
    return null;
  }
}
