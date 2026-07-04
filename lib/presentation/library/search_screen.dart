import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/logger.dart';
import '../../core/router.dart';
import '../../data/quote.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens.dart';
import '../providers.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/max_width_body.dart';
import '../widgets/quote_card.dart';
import '../widgets/xjk_icon.dart';

/// 全文搜索屏 —— L11 第一刀。
///
/// 视觉: TopBar 风格的 SearchBar (圆角 14px, fg-raised 底, 1px border1 描边),
/// 下方实时过滤的金句列表。空态文案沿用 skill 里"…？"的温和口吻。
///
/// 交互:
/// - tap 列表项 → 进入 [EditorScreen] (编辑模式)
/// - long-press → 删除确认 (跟 LibraryScreen 一致)
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _q = TextEditingController();
  final FocusNode _focus = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // 进屏自动唤起键盘
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _q.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final String trimmed = value.trim();
    if (trimmed == _query) return;
    setState(() => _query = trimmed);
    AppLogger.instance.debug('search query=$trimmed');
  }

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final AsyncValue<List<Quote>> async = ref.watch(quotesProvider);
    final List<Quote> all = async.value ?? const <Quote>[];
    final List<Quote> hits = filterQuotes(all, _query);

    return Scaffold(
      backgroundColor: t.bgPage,
      body: SafeArea(
        child: MaxWidthBody(
          child: Column(
            children: <Widget>[
              _SearchBar(
                controller: _q,
                focus: _focus,
                onChanged: _onChanged,
                onCancel: () => Navigator.of(context).maybePop(),
              ),
              Expanded(child: _buildBody(all, hits)),
            ],
          ),
        ),
      ),
    );
  }

  /// 三种状态: 没输入 / 没命中 / 有命中。拆出来避免三元嵌套读不懂。
  Widget _buildBody(List<Quote> all, List<Quote> hits) {
    if (_query.isEmpty) return _SearchHint(total: all.length);
    if (hits.isEmpty) return _SearchEmpty(query: _query);
    return _SearchResults(query: _query, results: hits);
  }
}

/// 纯函数: 在 [all] 里挑出文本或标签包含 [query] (大小写不敏感) 的句子。
///
/// 单独抽出来是为了让 search 行为可单测, 不需要 widget tree。
List<Quote> filterQuotes(List<Quote> all, String query) {
  final String q = query.trim();
  if (q.isEmpty) return const <Quote>[];
  final String lower = q.toLowerCase();
  return <Quote>[
    for (final Quote item in all)
      if (item.text.toLowerCase().contains(lower) ||
          item.tag.toLowerCase().contains(lower))
        item,
  ];
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focus,
    required this.onChanged,
    required this.onCancel,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final ValueChanged<String> onChanged;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: t.bgRaised,
                borderRadius: BorderRadius.circular(XJKTokens.radiusLg),
                border: Border.all(color: t.border1),
              ),
              child: Row(
                children: <Widget>[
                  XJKIcon('search', size: 18, color: t.fg3),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focus,
                      onChanged: onChanged,
                      textInputAction: TextInputAction.search,
                      inputFormatters: <TextInputFormatter>[
                        // 简单上限, 防异常长输入引起卡顿
                        LengthLimitingTextInputFormatter(80),
                      ],
                      style: TextStyle(
                        fontFamily: XJKTokens.serifDisplay,
                        fontSize: 15,
                        color: t.fg1,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: '搜你写过的句子…',
                        hintStyle: TextStyle(
                          fontFamily: XJKTokens.serifDisplay,
                          fontSize: 15,
                          color: t.fgMuted,
                        ),
                      ),
                    ),
                  ),
                  if (controller.text.isNotEmpty)
                    XJKIconButton(
                      icon: 'x',
                      size: 16,
                      color: t.fg3,
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: onCancel,
            child: Text(
              '取消',
              style: TextStyle(
                fontFamily: XJKTokens.serifDisplay,
                fontSize: 15,
                color: t.fg2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          total == 0 ? '金库还很空, 暂时没什么可搜。' : '在 $total 句里找一句。\n词或标签都行。',
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

class _SearchEmpty extends StatelessWidget {
  const _SearchEmpty({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          '没有找到"$query"。\n要不要换一个词试试？',
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

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query, required this.results});

  final String query;
  final List<Quote> results;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final XJKTokens t = XJKTheme.of(context);
    final DateFormat df = DateFormat('M月 d日', 'zh_CN');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            '${results.length} 句包含"$query"',
            style: TextStyle(
              fontFamily: XJKTokens.serifItalic,
              fontStyle: FontStyle.italic,
              fontSize: 12,
              color: t.fg3,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            itemCount: results.length,
            itemBuilder: (BuildContext context, int i) {
              final Quote q = results[i];
              return QuoteCard(
                quote: q.text,
                tag: q.tag,
                date: df.format(q.createdAt),
                onTap: () => _openEditor(context, q),
                onLongPress: () => _confirmDelete(context, ref, q),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openEditor(BuildContext context, Quote q) {
    context.push('${FolioRoutes.editorNew}/${q.id}');
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Quote q,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String failText = AppL10n.of(context).snackSaveFailed;
    final bool? ok = await showConfirmDeleteDialog(context);
    if (ok != true) return;
    final bool saved = await ref.read(quotesProvider.notifier).remove(q.id);
    if (!saved && context.mounted) {
      messenger.showSnackBar(SnackBar(content: Text(failText)));
    }
  }
}
