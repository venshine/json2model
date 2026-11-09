import 'package:flutter/material.dart';

/// 色板，沿用 WheelView 示例 App 的配色；浅色与深色两套字段一一对应
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.bg,
    required this.surface,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.codeBg,
    required this.codeText,
    required this.codeComment,
    required this.codeString,
    required this.codeKeyword,
    required this.codeType,
    required this.codeNumber,
    required this.segBg,
    required this.segOn,
    required this.accent,
    required this.accentInk,
    required this.accentSoft,
    required this.onAccent,
    required this.ok,
    required this.okSoft,
    required this.error,
    required this.errorSoft,
  });

  final Color bg;
  final Color surface;
  final Color border;
  final Color text;
  final Color textMuted;
  final Color codeBg;
  final Color codeText;
  final Color codeComment;
  final Color codeString;
  final Color codeKeyword;
  final Color codeType;
  final Color codeNumber;
  final Color segBg;
  final Color segOn;
  final Color accent;

  /// 强调色当文字用时的颜色：浅色背景上橙色对比度不足，换成加深的同色系
  final Color accentInk;
  final Color accentSoft;
  final Color onAccent;
  final Color ok;
  final Color okSoft;
  final Color error;
  final Color errorSoft;

  static const light = Palette(
    bg: Color(0xFFF4F2EE),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE4DFD6),
    text: Color(0xFF16181D),
    textMuted: Color(0xFF5C6370),
    codeBg: Color(0xFFFBFAF7),
    codeText: Color(0xFF24292F),
    codeComment: Color(0xFF646B77),
    codeString: Color(0xFF2F7D4F),
    codeKeyword: Color(0xFFC2410C),
    codeType: Color(0xFF1F5FBF),
    codeNumber: Color(0xFF8A4B08),
    segBg: Color(0xFFEFECE6),
    segOn: Color(0xFFFFFFFF),
    accent: Color(0xFFFF7A3D),
    accentInk: Color(0xFFC2410C),
    accentSoft: Color(0x1FFF7A3D),
    onAccent: Color(0xFF1A0E06),
    ok: Color(0xFF2F7D4F),
    okSoft: Color(0x1A2F7D4F),
    error: Color(0xFFB42318),
    errorSoft: Color(0x14B42318),
  );

  static const dark = Palette(
    bg: Color(0xFF0F1115),
    surface: Color(0xFF171A20),
    border: Color(0xFF23272F),
    text: Color(0xFFF2F1EC),
    textMuted: Color(0xFF9AA0AB),
    codeBg: Color(0xFF0B0D11),
    codeText: Color(0xFFE6E3DA),
    codeComment: Color(0xFF8A919C),
    codeString: Color(0xFFA8D8B9),
    codeKeyword: Color(0xFFFF7A3D),
    codeType: Color(0xFF8CC4FF),
    codeNumber: Color(0xFFF2C38B),
    segBg: Color(0xFF0F1115),
    segOn: Color(0xFF2A2F38),
    accent: Color(0xFFFF7A3D),
    accentInk: Color(0xFFFF7A3D),
    accentSoft: Color(0x1FFF7A3D),
    onAccent: Color(0xFF1A0E06),
    ok: Color(0xFF7FD6A0),
    okSoft: Color(0x1F7FD6A0),
    error: Color(0xFFFF8A80),
    errorSoft: Color(0x1FFF8A80),
  );

  @override
  Palette copyWith() => this;

  @override
  Palette lerp(Palette? other, double t) => t < 0.5 || other == null ? this : other;
}

extension PaletteContext on BuildContext {
  Palette get palette => Theme.of(this).extension<Palette>()!;
}

const monoFont = 'JetBrainsMono';
const sansFont = 'SpaceGrotesk';

ThemeData buildTheme(Brightness brightness) {
  final p = brightness == Brightness.dark ? Palette.dark : Palette.light;
  final base = ThemeData(
    brightness: brightness,
    fontFamily: sansFont,
    scaffoldBackgroundColor: p.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: p.accent,
      brightness: brightness,
      primary: p.accentInk,
      surface: p.surface,
    ),
    extensions: [p],
  );
  return base.copyWith(
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: p.accentInk,
      selectionColor: p.accentSoft.withValues(alpha: 0.35),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.text,
      contentTextStyle: TextStyle(fontFamily: sansFont, color: p.bg, fontWeight: FontWeight.w500),
    ),
  );
}
