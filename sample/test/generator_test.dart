import 'package:flutter_test/flutter_test.dart';
import 'package:json2model_sample/generator.dart';
import 'package:json2model_sample/presets.dart';

void main() {
  for (final preset in presets) {
    test('preset "${preset.label}" generates code that parses as Dart', () {
      final result = generate(preset.className, preset.json);
      expect(result.errorCode, isNull, reason: result.message);
      expect(result.verified, isTrue);
      expect(result.classes, greaterThan(0));
      expect(result.code, contains('fromJson'));
      expect(result.code, contains('toJson'));
    });
  }

  test('nested objects and object arrays become their own classes', () {
    final result = generate('order', presets.firstWhere((p) => p.label == 'Nested').json);
    expect(result.code, contains('class Order {'));
    expect(result.code, contains('class Customer {'));
    expect(result.code, contains('class Contact {'));
    expect(result.code, contains('final List<Items>? items;'));
    expect(result.code, contains('final List<dynamic>? coupons;'));
    expect(result.classes, 4);
  });

  test('keys that are not dart identifiers keep the original json key', () {
    final result = generate('item', presets.firstWhere((p) => p.label == 'Tricky keys').json);
    expect(result.verified, isTrue);
    expect(result.code, contains('final String? userName;'));
    expect(result.code, contains("json['user-name']"));
    expect(result.code, contains('final String? class_;'));
    expect(result.code, contains('final bool? n1st;'));
    // $ref 是合法标识符，原样保留，也要计入字段数
    expect(result.code, contains(r'final String? $ref;'));
    expect(result.fields, 7);
  });

  test('empty input reports E_EMPTY', () {
    expect(generate('a', '  ').errorCode, 'E_EMPTY');
  });

  test('invalid json reports E_JSON with the parser message', () {
    final result = generate('a', '{"a": 1,}');
    expect(result.errorCode, 'E_JSON');
    expect(result.message, startsWith('Invalid JSON'));
    expect(result.hasCode, isFalse);
  });

  test('a top-level primitive reports E_ROOT', () {
    expect(generate('a', '42').errorCode, 'E_ROOT');
    expect(generate('a', '"text"').errorCode, 'E_ROOT');
  });

  test('a class name that is not a dart identifier reports E_DART_SYNTAX and keeps the raw code', () {
    final result = generate('1abc', '{"a": 1}');
    expect(result.errorCode, 'E_DART_SYNTAX');
    expect(result.verified, isFalse);
    expect(result.code, contains('class 1abc'));
  });

  test('blank class name falls back to Model', () {
    expect(generate(' ', '{"a": 1}').code, contains('class Model {'));
  });

  test('prettyJson re-indents valid json and rejects invalid json', () {
    expect(prettyJson('{"a":[1,2]}'), '{\n  "a": [\n    1,\n    2\n  ]\n}');
    expect(prettyJson('{'), isNull);
  });
}
