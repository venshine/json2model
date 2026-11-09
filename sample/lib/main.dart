import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import 'palette.dart';
import 'playground_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicenses();
  runApp(const PlaygroundApp());
  // Web 上默认不生成无障碍树；打开后屏幕阅读器和自动化测试都能按标签找到控件
  if (kIsWeb) SemanticsBinding.instance.ensureSemantics();
}

/// 打包的字体为 SIL OFL 1.1，协议原文随 App 一起分发，在 Licenses 页可查看
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (name, file) in [
      ('Space Grotesk', 'SpaceGrotesk-OFL.txt'),
      ('JetBrains Mono', 'JetBrainsMono-OFL.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([name], await rootBundle.loadString('licenses/$file'));
    }
  });
}

class PlaygroundApp extends StatefulWidget {
  const PlaygroundApp({super.key, this.initialThemeMode = ThemeMode.system});

  final ThemeMode initialThemeMode;

  @override
  State<PlaygroundApp> createState() => _PlaygroundAppState();
}

class _PlaygroundAppState extends State<PlaygroundApp> {
  late var _mode = widget.initialThemeMode;

  void _toggleTheme(Brightness current) {
    setState(() => _mode = current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'json2model Playground',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: _mode,
      home: Builder(
        builder: (context) => PlaygroundPage(onToggleTheme: () => _toggleTheme(Theme.of(context).brightness)),
      ),
    );
  }
}
