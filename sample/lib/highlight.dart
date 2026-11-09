import 'package:flutter/painting.dart';

import 'palette.dart';

const _keywords = {
  'import', 'show', 'class', 'factory', 'final', 'this', 'return', 'null', 'true', 'false', 'dynamic', //
  'void', 'var', 'const', 'required', 'is', 'as', 'new', 'if', 'else',
};

// 小写开头的内置类型，与大写开头的类名同色
const _builtinTypes = {'int', 'double', 'num', 'bool'};

// 依次匹配：注释、单引号或双引号字符串、数字、标识符、其余单个字符
final _token = RegExp(r"""//[^\n]*|'(?:\\.|[^'\\\n])*'|"(?:\\.|[^"\\\n])*"|\b\d+(?:\.\d+)?\b|[A-Za-z_$][\w$]*|\s+|.""");

/// 生成代码的轻量语法高亮，只区分注释、字符串、数字、关键字和类型
TextSpan highlightDart(String code, Palette p, TextStyle base) {
  final spans = <TextSpan>[];
  for (final m in _token.allMatches(code)) {
    final t = m[0]!;
    var color = p.codeText;
    if (t.startsWith('//')) {
      color = p.codeComment;
    } else if (t.startsWith("'") || t.startsWith('"')) {
      color = p.codeString;
    } else if (RegExp(r'^\d').hasMatch(t)) {
      color = p.codeNumber;
    } else if (_keywords.contains(t)) {
      color = p.codeKeyword;
    } else if (_builtinTypes.contains(t) || RegExp(r'^[A-Z]').hasMatch(t)) {
      color = p.codeType;
    }
    final last = spans.isEmpty ? null : spans.last;
    // 相邻同色片段合并，减少 TextSpan 数量
    if (last != null && last.style?.color == color) {
      spans[spans.length - 1] = TextSpan(text: last.text! + t, style: last.style);
    } else {
      spans.add(
        TextSpan(
          text: t,
          style: TextStyle(color: color),
        ),
      );
    }
  }
  return TextSpan(style: base, children: spans);
}
