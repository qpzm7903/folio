import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/quote.dart';
import '../../theme/tokens.dart';
import '../editor/editor_screen.dart';
import '../providers.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/fab.dart';
import '../widgets/max_width_body.dart';
import '../widgets/quote_card.dart';
import '../widgets/section_header.dart';
import '../widgets/tag_row.dart';
import '../widgets/top_bar.dart';
import 'search_screen.dart';

/// 金库主屏 —— 对应 screens.jsx 的 `LibraryScreen`.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({this.onOpenDisplay, super.key});

  /// 点击"今日金句"卡跳转到屏保展示页。
  final VoidCallback? onOpenDisplay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final XJKTokens t = XJKTheme.of(context);
    final AsyncValue<List<Quote>> async = ref.watch(quotesProvider);
    final String activeTag = ref.watch(activeTagProvider);
    final List<String> tags = ref.watch(tagsProvider);

    return MaxWidthBody(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              XJKTopBar(
                title: '小金库',
                subtitle: 'est. 2026',
                actions: <XJKTopBarAction>[
                  XJKTopBarAction(
                    icon: 'search',
                    label: '搜索',
                    onPressed: () => _openSearch(context),
                  ),
                ],
              ),
              Expanded(
                child: async.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (Object e, StackTrace _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        '没能读到金库, 再试一次？\n$e',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: t.danger),
                      ),
                    ),
                  ),
                  data: (List<Quote> quotes) {
                    if (quotes.isEmpty) return const _LibraryEmpty();
                    final List<Quote> filtered = activeTag == '全部'
                        ? quotes
                        : quotes
                              .where((Quote q) => q.tag == activeTag)
                              .toList(growable: false);
                    if (filtered.isEmpty) {
                      return _LibraryNoMatch(tag: activeTag);
                    }
                    final Quote today = filtered.first;
                    final List<Quote> rest = filtered.skip(1).toList();
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      children: <Widget>[
                        const _HelloHero(),
                        const SizedBox(height: 12),
                        QuoteCard(
                          quote: today.text,
                          source: today.tag,
                          date: _fmtDate(today.createdAt),
                          variant: QuoteCardVariant.featured,
                          onTap: onOpenDisplay,
                        ),

                        const SizedBox(height: 12),
                        SectionHeader(title: '你的金库', count: quotes.length),
                        TagRow(
                          tags: tags,
                          active: activeTag,
                          onSelect: (String selected) =>
                              ref.read(activeTagProvider.notifier).state =
                                  selected,
                        ),
                        const SizedBox(height: 12),
                        for (final Quote q in rest)
                          QuoteCard(
                            quote: q.text,
                            source: q.tag,
                            date: _fmtDate(q.createdAt),
                            onTap: () => _openEditExisting(context, q),
                            onLongPress: () => _confirmDelete(context, ref, q),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 24 + MediaQuery.of(context).padding.bottom + 64,
            child: XJKFab(
              tooltip: '新的一句',
              onPressed: () => _openEditor(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditor(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const EditorScreen(),
      ),
    );
  }

  Future<void> _openEditExisting(BuildContext context, Quote q) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => EditorScreen(editing: q),
      ),
    );
  }

  Future<void> _openSearch(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const SearchScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Quote q,
  ) async {
    final bool? ok = await showConfirmDeleteDialog(context);
    if (ok == true) {
      await ref.read(quotesProvider.notifier).remove(q.id);
    }
  }

  String _fmtDate(DateTime t) {
    final DateFormat df = DateFormat('M月 d日', 'zh_CN');
    return df.format(t);
  }
}

/// 用 Builder 让它能 access tokens —— 显示 "今天的金句" 标签。
class _HelloHero extends StatelessWidget {
  const _HelloHero();

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        '今天的金句',
        style: TextStyle(
          fontFamily: XJKTokens.sansUi,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.8,
          color: t.fg3,
        ),
      ),
    );
  }
}

class _LibraryEmpty extends StatelessWidget {
  const _LibraryEmpty();

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '这里还很空。',
            style: TextStyle(
              fontFamily: XJKTokens.serifDisplay,
              fontSize: 22,
              color: t.fg1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '贴一句话进来，让它有一天\n突然出现在屏幕上。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: XJKTokens.serifDisplay,
              fontSize: 15,
              color: t.fg3,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryNoMatch extends StatelessWidget {
  const _LibraryNoMatch({required this.tag});
  final String tag;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          '这一类还没有。 「$tag」',
          style: TextStyle(color: t.fg3, fontFamily: XJKTokens.serifDisplay),
        ),
      ),
    );
  }
}
