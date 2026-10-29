import 'dart:io';

import 'package:json2model/json2model.dart';
import 'package:test/test.dart';

/// 把生成的模型代码和一段 main 写到临时文件，用 dart 实际运行，返回标准输出
Future<String> runGenerated(String model, String body) async {
  var dir = Directory.systemTemp.createTempSync('json2model_test');
  try {
    var file = File('${dir.path}/main.dart')..writeAsStringSync('$model\nvoid main() {\n$body\n}\n');
    var result = await Process.run(Platform.resolvedExecutable, ['run', file.path]);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    return (result.stdout as String).trim();
  } finally {
    dir.deleteSync(recursive: true);
  }
}

void main() {
  test('keys that are not valid dart identifiers still generate compilable code', () async {
    var model = parse('item', r'''{"user-name": "a", "class": 1, "1st": true, "it's": "x", "$ref": "r", "_id": 1, "id": 2}''');
    var output = await runGenerated(model, r'''
  var item = itemFromJson('{"user-name": "b", "class": 2, "1st": false, "it\'s": "y", "\$ref": "s", "_id": 3, "id": 4}');
  print(itemToJson(item));
''');
    expect(output, r'''{"user-name":"b","class":2,"1st":false,"it's":"y","$ref":"s","_id":3,"id":4}''');
  });

  test('double field accepts integer json values', () async {
    var model = parse('item', '{"price": 10.5, "tags": [1.5, 2.5]}');
    var output = await runGenerated(model, '''
  var item = itemFromJson('{"price": 10, "tags": [1, 2.5]}');
  print(itemToJson(item));
''');
    expect(output, '{"price":10.0,"tags":[1.0,2.5]}');
  });
}
