import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens.dart';
import '../providers.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/max_width_body.dart';
import '../widgets/top_bar.dart';
import '../widgets/xjk_icon.dart';

/// 标签管理屏 —— L11 收尾。
///
/// 列出 quotes 里出现过的所有标签 + 每个的句数 (按句数倒序),
/// tap 进入重命名 sheet, 在 sheet 里也能"取下"整组标签。
///
/// 这屏不动任何 quote 文本, 只动它们的 [Quote.tag] 字段。
class TagsScreen extends ConsumerWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final XJKTokens t = XJKTheme.of(context);
    final List<TagCount> tags = ref.watch(tagCountsProvider);

    return Scaffold(
      backgroundColor: t.bgPage,
      body: SafeArea(
        child: MaxWidthBody(
          child: Column(
            children: <Widget>[
              XJKTopBar(
                title: '标签管理',
                subtitle: 'tags',
                leading: XJKIconButton(
                  icon: 'chevron-left',
                  tooltip: '返回',
                  onPressed: () {
                    // 标签管理屏是从 settings push 进来的, 优先 pop 回 settings;
                    // 兜底 go 回 library (顶层 tab).
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/library');
                    }
                  },
                ),
              ),
              Expanded(
                child: tags.isEmpty
                    ? const _TagsEmpty()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                        itemCount: tags.length,
                        separatorBuilder: (BuildContext _, int __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (BuildContext _, int i) {
                          final TagCount tc = tags[i];
                          return _TagRow(
                            tag: tc.tag,
                            count: tc.count,
                            onTap: () => _openEditor(context, ref, tc),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref,
    TagCount tc,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext _) => _TagEditSheet(tag: tc.tag, count: tc.count),
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({required this.tag, required this.count, required this.onTap});

  final String tag;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Material(
      color: t.bgRaised,
      borderRadius: BorderRadius.circular(XJKTokens.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(XJKTokens.radiusLg),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(XJKTokens.radiusLg),
            border: Border.all(color: t.border1),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  tag,
                  style: TextStyle(
                    fontFamily: XJKTokens.serifDisplay,
                    fontSize: 16,
                    color: t.fg1,
                  ),
                ),
              ),
              Text(
                '$count 句',
                style: TextStyle(
                  fontFamily: XJKTokens.serifItalic,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                  color: t.fg3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagsEmpty extends StatelessWidget {
  const _TagsEmpty();

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          '还没有任何标签。\n给一句话加个标签, 让它有归处。',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: XJKTokens.serifDisplay,
            fontSize: 16,
            height: 1.8,
            color: t.fg3,
          ),
        ),
      ),
    );
  }
}

class _TagEditSheet extends ConsumerStatefulWidget {
  const _TagEditSheet({required this.tag, required this.count});

  final String tag;
  final int count;

  @override
  ConsumerState<_TagEditSheet> createState() => _TagEditSheetState();
}

class _TagEditSheetState extends ConsumerState<_TagEditSheet> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.tag);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String next = _name.text.trim();
    if (next.isEmpty || next == widget.tag) {
      unawaited(navigator.maybePop());
      return;
    }
    final bool saved =
        await ref.read(quotesProvider.notifier).renameTag(widget.tag, next);
    if (!mounted) return;
    if (!saved) {
      messenger.showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).snackSaveFailed)),
      );
      return; // sheet 不关, 名字还在输入框里, 可重试
    }
    unawaited(navigator.maybePop());
    messenger.showSnackBar(
      SnackBar(content: Text('「${widget.tag}」改成「$next」。')),
    );
  }

  Future<void> _remove() async {
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool? ok = await showConfirmDeleteDialog(
      context,
      message: '从所有句子上取下「${widget.tag}」？',
      removeLabel: '取下',
    );
    if (ok != true) return;
    final bool saved =
        await ref.read(quotesProvider.notifier).removeTag(widget.tag);
    if (!mounted) return;
    if (!saved) {
      messenger.showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).snackSaveFailed)),
      );
      return;
    }
    unawaited(navigator.maybePop());
    messenger.showSnackBar(
      SnackBar(content: Text('「${widget.tag}」已从 ${widget.count} 句上取下。')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final MediaQueryData media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + media.viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            '改个名字',
            style: TextStyle(
              fontFamily: XJKTokens.serifDisplay,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: t.fg1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '会改写「${widget.tag}」标在的 ${widget.count} 句。',
            style: TextStyle(
              fontFamily: XJKTokens.serifDisplay,
              fontSize: 14,
              color: t.fg3,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            autofocus: true,
            decoration: const InputDecoration(hintText: '新标签…'),
            style: TextStyle(
              fontFamily: XJKTokens.serifDisplay,
              fontSize: 16,
              color: t.fg1,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _save, child: const Text('改好')),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _remove,
            child: Text(
              '从所有句子上取下',
              style: TextStyle(
                color: t.danger,
                fontFamily: XJKTokens.serifDisplay,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
