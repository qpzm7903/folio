import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/quote.dart';
import '../../theme/tokens.dart';
import '../import/import_sheet.dart';
import '../providers.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/max_width_body.dart';
import '../widgets/top_bar.dart';

/// 金句编辑屏 —— 对应 screens.jsx 的 `EditorScreen`。
///
/// 两种模式:
/// - 新建: `EditorScreen()`, 标题 "新的一句", 右上角支持批量导入
/// - 编辑: `EditorScreen(editing: quote)`, 标题 "改一改",
///   表单预填, 保存时调 `update(id, ...)` 而非 `add`
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({this.editing, super.key});

  /// 非空 → 编辑模式。
  final Quote? editing;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late final TextEditingController _text;
  late final TextEditingController _tag;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.editing?.text ?? '');
    _tag = TextEditingController(text: widget.editing?.tag ?? '');
  }

  @override
  void dispose() {
    _text.dispose();
    _tag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final bool canSave = _text.text.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: t.bgPage,
      body: SafeArea(
        child: MaxWidthBody(
          child: Column(
            children: <Widget>[
              XJKTopBar(
                title: _isEditing ? '改一改' : '新的一句',
                actions: <XJKTopBarAction>[
                  if (!_isEditing)
                    XJKTopBarAction(
                      icon: 'upload',
                      label: '批量导入',
                      onPressed: () => _openImport(context),
                    ),
                  if (_isEditing)
                    XJKTopBarAction(
                      icon: 'trash-2',
                      label: '取出',
                      onPressed: _confirmDelete,
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
                          autofocus: !_isEditing,
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
                              borderSide: BorderSide(
                                color: t.accent,
                                width: 1.5,
                              ),
                            ),
                            filled: true,
                            fillColor: t.bgRaised,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _tag,
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
                          child: Text(_isEditing ? '存下来' : '收入金库'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    if (_isEditing) {
      await ref
          .read(quotesProvider.notifier)
          .update(widget.editing!.id, _text.text, _tag.text);
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('已经改好。')));
    } else {
      await ref.read(quotesProvider.notifier).add(_text.text, _tag.text);
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('已收入金库。')));
    }
    unawaited(navigator.maybePop());
  }

  Future<void> _confirmDelete() async {
    final NavigatorState navigator = Navigator.of(context);
    final bool? ok = await showConfirmDeleteDialog(context);
    if (ok != true) return;
    await ref.read(quotesProvider.notifier).remove(widget.editing!.id);
    if (!mounted) return;
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
