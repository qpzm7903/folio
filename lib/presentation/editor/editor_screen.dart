import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/tokens.dart';
import '../import/import_sheet.dart';
import '../providers.dart';
import '../widgets/top_bar.dart';

/// 新建金句 —— 对应 screens.jsx 的 `EditorScreen`.
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final TextEditingController _text = TextEditingController();
  final TextEditingController _src = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    _src.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final bool canSave = _text.text.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: t.bgPage,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            XJKTopBar(
              title: '新的一句',
              actions: <XJKTopBarAction>[
                XJKTopBarAction(
                  icon: 'upload',
                  label: '批量导入',
                  onPressed: () => _openImport(context),
                ),
                XJKTopBarAction(
                  icon: 'x',
                  label: '关闭',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _text,
                        autofocus: true,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                          fontFamily: XJKTokens.serifDisplay,
                          fontSize: 18,
                          height: 1.75,
                          color: t.fg1,
                        ),
                        decoration: InputDecoration(
                          hintText: '写下一句你最近读到的话…',
                          hintStyle: TextStyle(
                            fontFamily: XJKTokens.serifDisplay,
                            fontSize: 18,
                            color: t.fgMuted,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              XJKTokens.radiusLg,
                            ),
                            borderSide: BorderSide(color: t.border1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              XJKTokens.radiusLg,
                            ),
                            borderSide: BorderSide(color: t.border1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              XJKTokens.radiusLg,
                            ),
                            borderSide: BorderSide(color: t.accent, width: 1.5),
                          ),
                          filled: true,
                          fillColor: t.bgRaised,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _src,
                      decoration: InputDecoration(
                        hintText: '— 出处 / 标签（可留空）',
                        hintStyle: TextStyle(
                          fontFamily: XJKTokens.serifItalic,
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                          color: t.fgMuted,
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: XJKTokens.serifItalic,
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: t.fg2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Opacity(
                      opacity: canSave ? 1 : 0.4,
                      child: ElevatedButton(
                        onPressed: canSave ? _save : null,
                        child: const Text('收入金库'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    await ref.read(quotesProvider.notifier).add(_text.text, _src.text);
    if (!mounted) return;
    final NavigatorState navigator = Navigator.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已收入金库。')));
    unawaited(navigator.maybePop());
  }

  Future<void> _openImport(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext _) => const ImportSheet(),
    );
  }
}
