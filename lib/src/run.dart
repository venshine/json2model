import 'dart:io';

import 'package:args/args.dart' show ArgParser;

import 'json_model.dart' show parse;

void run([List<String> args = const []]) {
  var parser = ArgParser()
    ..addOption('src', abbr: 's', defaultsTo: 'json', help: 'Input the json directory or file.')
    ..addOption('dst', abbr: 'd', defaultsTo: 'lib/models', help: 'Input the model directory.');
  var result = parser.parse(args);
  _sync(result['src'], result['dst']);
}

void _sync(String srcPath, String destPath) {
  if (FileSystemEntity.isFileSync(srcPath)) {
    _syncFile(srcPath, destPath);
  } else {
    _syncDir(srcPath, destPath);
  }
}

void _syncDir(String srcPath, String destPath) {
  var srcDir = Directory(srcPath);
  if (!srcDir.existsSync()) {
    print('Source directory does not exist');
    return;
  }

  var listFiles = srcDir.listSync(recursive: true);
  if (listFiles.isEmpty) {
    print('Source file does not exist');
    return;
  }

  for (var element in listFiles) {
    if (FileSystemEntity.isFileSync(element.path)) {
      var path = destPath;
      if (element.path.split('/').length > 2) {
        path += element.path.substring(element.path.indexOf('/'), element.path.lastIndexOf('/'));
      }
      _syncFile(element.path, path);
    }
  }
}

void _syncFile(String srcPath, String destPath) {
  var destDir = Directory(destPath);
  if (!destDir.existsSync()) {
    destDir.createSync(recursive: true);
  }
  var file = File(srcPath);
  if (file.existsSync()) {
    var name = srcPath.contains('.')
        ? srcPath.substring(srcPath.lastIndexOf('/') != -1 ? srcPath.lastIndexOf('/') + 1 : 0, srcPath.lastIndexOf('.'))
        : srcPath;
    var contents = parse(name, file.readAsStringSync());
    File('${destDir.path}/$name.dart')
      ..createSync()
      ..writeAsStringSync(contents);
    print('Generate $name.dart file success');
  }
}
