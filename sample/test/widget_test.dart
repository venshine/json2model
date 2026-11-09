import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json2model_sample/main.dart';

String outputText(WidgetTester tester) =>
    tester.widget<SelectableText>(find.byKey(const Key('dart-output'))).textSpan!.toPlainText();

Future<void> pumpApp(WidgetTester tester, {Size size = const Size(1280, 800), ThemeMode mode = ThemeMode.light}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(PlaygroundApp(initialThemeMode: mode));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('first preset is generated on launch', (tester) async {
    await pumpApp(tester);
    expect(outputText(tester), contains('class User {'));
    expect(outputText(tester), contains('class Address {'));
    expect(find.text('Valid Dart'), findsOneWidget);
    expect(find.text('2 classes · 9 fields'), findsOneWidget);
  });

  testWidgets('choosing a preset regenerates with its class name', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('preset-Array')));
    await tester.pumpAndSettle();
    expect(outputText(tester), contains('List<Products> productsFromJson(String str)'));
    expect(tester.widget<TextField>(find.byKey(const Key('class-name'))).controller!.text, 'products');
  });

  testWidgets('editing the class name renames the generated class', (tester) async {
    await pumpApp(tester);
    await tester.enterText(find.byKey(const Key('class-name')), 'account');
    await tester.pumpAndSettle();
    expect(outputText(tester), contains('class Account {'));
    expect(outputText(tester), contains('Account accountFromJson(String str)'));
  });

  testWidgets('invalid json shows the error code and keeps the last code dimmed', (tester) async {
    await pumpApp(tester);
    await tester.enterText(find.byKey(const Key('json-input')), '{"a": ');
    await tester.pumpAndSettle();
    expect(find.textContaining('E_JSON'), findsOneWidget);
    expect(find.text('Waiting for valid JSON…'), findsOneWidget);
    // 右侧仍展示上一次的结果，复制按钮不可用
    expect(outputText(tester), contains('class User {'));
    expect(tester.widget<ButtonStyleButton>(find.byKey(const Key('copy'))).onPressed, isNull);

    await tester.enterText(find.byKey(const Key('json-input')), '{"a": 1}');
    await tester.pumpAndSettle();
    expect(find.text('Valid JSON'), findsOneWidget);
    expect(find.text('Waiting for valid JSON…'), findsNothing);
  });

  testWidgets('format re-indents the json input', (tester) async {
    await pumpApp(tester);
    await tester.enterText(find.byKey(const Key('json-input')), '{"a":{"b":1}}');
    await tester.tap(find.byKey(const Key('format')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byKey(const Key('json-input'))).controller!.text,
      '{\n  "a": {\n    "b": 1\n  }\n}',
    );
  });

  testWidgets('copy puts the generated code on the clipboard', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
      return null;
    });
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('copy')));
    await tester.pump();
    expect(copied, contains('class User {'));
    expect(find.text('Copied'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('theme toggle switches between light and dark', (tester) async {
    await pumpApp(tester);
    Brightness brightness() => Theme.of(tester.element(find.byKey(const Key('copy')))).brightness;
    expect(brightness(), Brightness.light);
    await tester.tap(find.byKey(const Key('theme-toggle')));
    await tester.pumpAndSettle();
    expect(brightness(), Brightness.dark);
  });

  testWidgets('narrow screens stack the panels without overflow', (tester) async {
    await pumpApp(tester, size: const Size(390, 844), mode: ThemeMode.dark);
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('json-input')), findsOneWidget);
    // 页面里还有代码区和输入框的 Scrollable，这里只滚外层列表
    final page = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.byKey(const Key('copy')), 200, scrollable: page);
    expect(tester.getRect(find.byKey(const Key('copy'))).bottom, lessThanOrEqualTo(844));
    expect(tester.takeException(), isNull);
  });
}
