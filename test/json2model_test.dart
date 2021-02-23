import 'package:json2model/json2model.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    test('Description of the test', run);
    test('Description of the test', () {
      run(['--src=example/json', '--dst=example/lib/models']);
    });
    test('Description of the test', () {
      run(['--src', 'example/json', '--dst', 'example/lib/models']);
    });
    test('Description of the test', () {
      run(['-s', 'example/json', '-d', 'example/lib/models']);
    });
    test('Description of the test', () {
      run(['-sexample/json', '-dexample/lib/models']);
    });
  });
}
