import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'generator.dart';
import 'highlight.dart';
import 'palette.dart';
import 'presets.dart';

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  final _json = TextEditingController(text: presets.first.json);
  final _name = TextEditingController(text: presets.first.className);
  late GenerateResult _result;

  /// 最近一次生成出代码的结果；输入暂时无效时继续展示它（变暗），避免右侧闪空
  GenerateResult? _lastCode;
  bool _copied = false;
  Timer? _copiedTimer;

  @override
  void initState() {
    super.initState();
    _regenerate();
    _json.addListener(_onInputChanged);
    _name.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _copiedTimer?.cancel();
    _json.dispose();
    _name.dispose();
    super.dispose();
  }

  void _regenerate() {
    _result = generate(_name.text, _json.text);
    if (_result.hasCode) _lastCode = _result;
  }

  void _onInputChanged() => setState(_regenerate);

  void _applyPreset(Preset preset) {
    // 先改类名再改 JSON，两次监听回调只有最后一次的结果生效
    _name.text = preset.className;
    _json.text = preset.json;
  }

  void _formatJson() {
    final pretty = prettyJson(_json.text);
    if (pretty != null) _json.text = pretty;
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _result.code));
    if (!mounted) return;
    setState(() => _copied = true);
    _copiedTimer?.cancel();
    _copiedTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 860;
            final pad = wide ? 28.0 : 16.0;
            final input = _JsonPanel(json: _json, name: _name, result: _result, onFormat: _formatJson);
            final output = _DartPanel(result: _result, lastCode: _lastCode, copied: _copied, onCopy: _copy);
            final header = <Widget>[
              _Header(onToggleTheme: widget.onToggleTheme),
              const SizedBox(height: 18),
              _PresetBar(current: _json.text, onSelect: _applyPreset),
              const SizedBox(height: 16),
            ];
            if (wide) {
              return Padding(
                padding: EdgeInsets.fromLTRB(pad, 22, pad, pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...header,
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 5, child: input),
                          const SizedBox(width: 16),
                          Expanded(flex: 6, child: output),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView(
              padding: EdgeInsets.fromLTRB(pad, 16, pad, pad),
              children: [
                ...header,
                SizedBox(height: 380, child: input),
                const SizedBox(height: 16),
                SizedBox(height: 560, child: output),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: p.accent, borderRadius: BorderRadius.circular(11)),
          child: Text(
            '{}',
            style: TextStyle(fontFamily: monoFont, fontWeight: FontWeight.w700, fontSize: 17, color: p.onAccent),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'json2model'),
                    TextSpan(
                      text: '  Playground',
                      style: TextStyle(color: p.textMuted, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: p.text, letterSpacing: -0.2),
              ),
              const SizedBox(height: 2),
              Text(
                'Paste JSON, get null-safe Dart models with fromJson / toJson.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.5, color: p.textMuted, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Licenses',
          onPressed: () => showLicensePage(context: context, applicationName: 'json2model Playground'),
          icon: Icon(Icons.info_outline_rounded, color: p.textMuted),
        ),
        IconButton(
          key: const Key('theme-toggle'),
          tooltip: dark ? 'Light mode' : 'Dark mode',
          onPressed: onToggleTheme,
          icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: p.text),
        ),
      ],
    );
  }
}

class _PresetBar extends StatelessWidget {
  const _PresetBar({required this.current, required this.onSelect});

  final String current;
  final ValueChanged<Preset> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text(
            'Try',
            style: TextStyle(color: p.textMuted, fontWeight: FontWeight.w500),
          ),
        ),
        for (final preset in presets)
          _Pill(
            key: Key('preset-${preset.label}'),
            label: preset.label,
            selected: preset.json == current,
            onTap: () => onSelect(preset),
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? p.accent : p.surface,
        shape: StadiumBorder(side: BorderSide(color: selected ? p.accent : p.border)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? p.onAccent : p.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 左右两个面板的公共外框：标题栏 + 内容 + 可选底栏
class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.actions, required this.body, this.footer});

  final String title;
  final List<Widget> actions;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: p.text),
                  ),
                  const SizedBox(width: 12),
                  ...actions,
                ],
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: p.border),
          Expanded(
            child: ColoredBox(color: p.codeBg, child: body),
          ),
          if (footer != null) ...[Divider(height: 1, thickness: 1, color: p.border), footer!],
        ],
      ),
    );
  }
}

// 关闭 JetBrains Mono 的连字，`=>` 等符号按原样显示，避免读者误以为代码里就是箭头字符
TextStyle _codeStyle(Palette p) => TextStyle(
  fontFamily: monoFont,
  fontSize: 13,
  height: 1.55,
  color: p.codeText,
  fontFeatures: const [FontFeature.disable('calt'), FontFeature.disable('liga')],
);

class _JsonPanel extends StatelessWidget {
  const _JsonPanel({required this.json, required this.name, required this.result, required this.onFormat});

  final TextEditingController json;
  final TextEditingController name;
  final GenerateResult result;
  final VoidCallback onFormat;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    // E_DART_SYNTAX 是生成结果的问题，在右侧展示；其余错误都出在输入上
    final inputError = result.errorCode != null && result.errorCode != 'E_DART_SYNTAX';
    return _Panel(
      title: 'JSON',
      actions: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Class',
                style: TextStyle(fontSize: 13, color: p.textMuted, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              // 窄屏下输入框可以收窄，避免标题栏溢出
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 132, maxHeight: 34),
                  child: TextField(
                    key: const Key('class-name'),
                    controller: name,
                    style: TextStyle(fontFamily: monoFont, fontSize: 13, color: p.text),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'model',
                      filled: true,
                      fillColor: p.codeBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: p.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: p.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: p.accent),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              TextButton(
                key: const Key('format'),
                onPressed: onFormat,
                style: TextButton.styleFrom(foregroundColor: p.accentInk),
                child: const Text('Format', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
      body: TextField(
        key: const Key('json-input'),
        controller: json,
        expands: true,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textAlignVertical: TextAlignVertical.top,
        style: _codeStyle(p),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.fromLTRB(16, 14, 16, 14),
          hintText: 'Paste JSON here',
        ),
      ),
      footer: _StatusBar(
        key: const Key('json-status'),
        ok: !inputError,
        text: inputError ? '${result.errorCode}  ${result.message}' : 'Valid JSON',
      ),
    );
  }
}

class _DartPanel extends StatelessWidget {
  const _DartPanel({required this.result, required this.lastCode, required this.copied, required this.onCopy});

  final GenerateResult result;
  final GenerateResult? lastCode;
  final bool copied;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final shown = result.hasCode ? result : lastCode;
    final stale = !result.hasCode;
    return _Panel(
      title: 'Dart',
      actions: [
        // 统计文字占满中间的剩余空间，让徽章和复制按钮贴右
        Expanded(
          child: shown == null
              ? const SizedBox.shrink()
              : Text(
                  '${shown.classes} ${shown.classes == 1 ? 'class' : 'classes'} · ${shown.fields} fields',
                  key: const Key('dart-stats'),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: p.textMuted, fontWeight: FontWeight.w500),
                ),
        ),
        if (result.hasCode) ...[
          _Badge(
            key: const Key('dart-verified'),
            ok: result.verified,
            text: result.verified ? 'Valid Dart' : 'Syntax error',
            compact: MediaQuery.sizeOf(context).width < 600,
          ),
          const SizedBox(width: 10),
        ],
        FilledButton.icon(
          key: const Key('copy'),
          onPressed: result.hasCode ? onCopy : null,
          style: FilledButton.styleFrom(
            backgroundColor: p.accent,
            foregroundColor: p.onAccent,
            visualDensity: VisualDensity.compact,
            textStyle: const TextStyle(fontFamily: sansFont, fontWeight: FontWeight.w700),
          ),
          icon: Icon(copied ? Icons.check_rounded : Icons.copy_rounded, size: 16),
          label: Text(copied ? 'Copied' : 'Copy'),
        ),
      ],
      body: Stack(
        children: [
          if (shown != null)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: stale ? 0.35 : 1,
                duration: const Duration(milliseconds: 180),
                child: _CodeView(code: shown.code),
              ),
            ),
          if (result.errorCode == 'E_DART_SYNTAX')
            Positioned(left: 12, right: 12, bottom: 12, child: _ErrorCard(text: result.message!)),
          if (stale)
            Center(
              child: Text(
                shown == null ? 'Generated code shows up here.' : 'Waiting for valid JSON…',
                style: TextStyle(color: p.textMuted, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }
}

class _CodeView extends StatelessWidget {
  const _CodeView({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText.rich(key: const Key('dart-output'), highlightDart(code.trimRight(), p, _codeStyle(p))),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({super.key, required this.ok, required this.text});

  final bool ok;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = ok ? p.ok : p.error;
    return Container(
      color: ok ? p.surface : p.errorSoft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle_rounded : Icons.error_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: ok ? p.textMuted : p.error, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({super.key, required this.ok, required this.text, this.compact = false});

  final bool ok;
  final String text;

  /// 只显示图标，文字放进 tooltip 和无障碍标签
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = ok ? p.ok : p.error;
    return Tooltip(
      message: compact ? text : '',
      child: Semantics(
        label: compact ? text : null,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: compact ? 5 : 9, vertical: 4),
          decoration: BoxDecoration(color: ok ? p.okSoft : p.errorSoft, borderRadius: BorderRadius.circular(999)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(ok ? Icons.verified_rounded : Icons.error_rounded, size: 14, color: color),
              if (!compact) ...[
                const SizedBox(width: 5),
                Text(
                  text,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.error),
      ),
      child: Text(
        'E_DART_SYNTAX  $text',
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontFamily: monoFont, fontSize: 12, color: p.error),
      ),
    );
  }
}
