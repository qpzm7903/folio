import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router.dart';
import '../../data/quote.dart';
import '../../domain/quote_display.dart';
import '../../domain/tag_filter.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens.dart';
import '../providers.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/fab.dart';
import '../widgets/max_width_body.dart';
import '../widgets/quote_card.dart';
import '../widgets/section_header.dart';
import '../widgets/tag_row.dart';
import '../widgets/top_bar.dart';
import '../widgets/xjk_icon.dart';

/// 金库主屏 —— 对应 screens.jsx 的 `LibraryScreen`.
///
/// 普通模式: 今日金句 + 标签筛选 + 金句列表 + 新增 FAB。
/// 多选模式 (`_selecting`): 顶栏换成「选择条」, 整列卡片可勾选, 底部出现
/// 「取出 N 句」批量删除栏。对应 screens.jsx 的 select-mode 分支。
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _selecting = false;
  bool _managingTags = false;
  Set<String> _picked = <String>{};

  void _enterSelect() => setState(() {
        _selecting = true;
        _picked = <String>{};
      });

  void _exitSelect() => setState(() {
        _selecting = false;
        _picked = <String>{};
      });

  void _toggle(String id) {
    final Set<String> next = Set<String>.of(_picked);
    if (!next.add(id)) next.remove(id);
    setState(() => _picked = next);
  }

  void _toggleAll(List<Quote> filtered) {
    final bool allPicked = filtered.isNotEmpty &&
        filtered.every((Quote q) => _picked.contains(q.id));
    setState(() {
      _picked = allPicked
          ? <String>{}
          : filtered.map((Quote q) => q.id).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final AsyncValue<List<Quote>> async = ref.watch(quotesProvider);
    final String activeTag = ref.watch(activeTagProvider);
    final List<String> tags = ref.watch(tagsProvider);
    final List<Quote> quotes = async.valueOrNull ?? const <Quote>[];

    if (_selecting) {
      final List<Quote> filtered = filterQuotesByTag(quotes, activeTag);
      return MaxWidthBody(child: _buildSelectMode(context, l10n, filtered));
    }
    return MaxWidthBody(
      child: _buildNormalMode(context, l10n, async, quotes, activeTag, tags),
    );
  }

  // ── 普通模式 ──────────────────────────────────────────────
  Widget _buildNormalMode(
    BuildContext context,
    AppL10n l10n,
    AsyncValue<List<Quote>> async,
    List<Quote> quotes,
    String activeTag,
    List<String> tags,
  ) {
    final XJKTokens t = XJKTheme.of(context);
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            XJKTopBar(
              title: l10n.appTitle,
              subtitle: l10n.appSubtitle,
              actions: <XJKTopBarAction>[
                XJKTopBarAction(
                  icon: 'search',
                  label: l10n.actionSearch,
                  onPressed: () => _openSearch(context),
                ),
                if (quotes.isNotEmpty)
                  XJKTopBarAction(
                    icon: 'check-square',
                    label: l10n.actionMultiSelect,
                    onPressed: _enterSelect,
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
                data: (List<Quote> all) {
                  if (all.isEmpty) return const _LibraryEmpty();
                  final List<Quote> filtered = filterQuotesByTag(all, activeTag);
                  if (filtered.isEmpty) {
                    return _LibraryNoMatch(tag: activeTag);
                  }
                  final Quote today = filtered.first;
                  final List<Quote> rest = filtered.skip(1).toList();
                  // Issue #12: 金库条目多时给一条可拖动的滚动条, 便于快速定位。
                  return Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    child: ListView(
                      primary: true,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      children: <Widget>[
                        const _HelloHero(),
                        const SizedBox(height: 12),
                        QuoteCard(
                          quote: displayQuoteText(today.text),
                          tag: today.tag,
                          date: _fmtDate(today.createdAt),
                          variant: QuoteCardVariant.featured,
                          onTap: () => context.go(FolioRoutes.display),
                        ),
                        const SizedBox(height: 12),
                        SectionHeader(
                          title: l10n.yourLibrary,
                          count: all.length,
                        ),
                        TagRow(
                          tags: tags,
                          active: activeTag,
                          onSelect: (String selected) => ref
                              .read(activeTagProvider.notifier)
                              .state = selected,
                          managing: _managingTags,
                          onToggleManaging: () => setState(
                            () => _managingTags = !_managingTags,
                          ),
                          onDeleteTag: (String tag) =>
                              _confirmDeleteTag(context, tag),
                        ),
                        const SizedBox(height: 12),
                        for (final Quote q in rest)
                          QuoteCard(
                            quote: displayQuoteText(q.text),
                            tag: q.tag,
                            date: _fmtDate(q.createdAt),
                            onTap: () => _openEditExisting(context, q),
                            onLongPress: () => _confirmDeleteOne(context, q),
                          ),
                      ],
                    ),
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
            tooltip: l10n.fabNewQuote,
            onPressed: () => _openEditor(context),
          ),
        ),
      ],
    );
  }

  // ── 多选模式 ──────────────────────────────────────────────
  Widget _buildSelectMode(
    BuildContext context,
    AppL10n l10n,
    List<Quote> filtered,
  ) {
    final bool allPicked = filtered.isNotEmpty &&
        filtered.every((Quote q) => _picked.contains(q.id));
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            _SelectBar(
              count: _picked.length,
              allPicked: allPicked,
              onCancel: _exitSelect,
              onToggleAll: () => _toggleAll(filtered),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? _SelectEmpty(text: l10n.selectEmptyNote)
                  : Scrollbar(
                      thumbVisibility: true,
                      interactive: true,
                      child: ListView(
                        primary: true,
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                        children: <Widget>[
                          for (final Quote q in filtered)
                            QuoteCard(
                              quote: displayQuoteText(q.text),
                              tag: q.tag,
                              date: _fmtDate(q.createdAt),
                              selectable: true,
                              selected: _picked.contains(q.id),
                              onToggle: () => _toggle(q.id),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).padding.bottom + 64,
          child: _RemoveActionBar(
            label: _picked.isEmpty
                ? l10n.actionRemove
                : l10n.removeSelected(_picked.length),
            enabled: _picked.isNotEmpty,
            onPressed: () => _confirmRemoveSelected(context, l10n),
          ),
        ),
      ],
    );
  }

  void _openEditor(BuildContext context) => context.push(FolioRoutes.editorNew);

  void _openEditExisting(BuildContext context, Quote q) =>
      context.push('${FolioRoutes.editorNew}/${q.id}');

  void _openSearch(BuildContext context) => context.push(FolioRoutes.search);

  /// 管理态点具名标签 → 确认后删除标签: 句子归「未分类」(tag 清空),
  /// 若正筛选被删标签则回「全部」。文案对齐 screens.jsx ConfirmDialog。
  Future<void> _confirmDeleteTag(BuildContext context, String tag) async {
    final AppL10n l10n = AppL10n.of(context);
    final bool? ok = await showConfirmDeleteDialog(
      context,
      message: l10n.deleteTagTitle(tag),
      detail: l10n.deleteTagBody,
      keepLabel: l10n.actionCancel,
      removeLabel: l10n.deleteTagConfirm,
    );
    if (ok != true || !mounted) return;
    await ref.read(quotesProvider.notifier).removeTag(tag);
    if (!mounted) return;
    if (ref.read(activeTagProvider) == tag) {
      ref.read(activeTagProvider.notifier).state = kAllTagsLabel;
    }
  }

  Future<void> _confirmDeleteOne(BuildContext context, Quote q) async {
    final bool? ok = await showConfirmDeleteDialog(context);
    if (ok == true) {
      await ref.read(quotesProvider.notifier).remove(q.id);
    }
  }

  Future<void> _confirmRemoveSelected(
    BuildContext context,
    AppL10n l10n,
  ) async {
    final int count = _picked.length;
    if (count == 0) return;
    final bool? ok = await showConfirmDeleteDialog(
      context,
      message: l10n.confirmRemoveSelected(count),
      detail: l10n.confirmRemoveSelectedBody,
    );
    if (ok != true) return;
    await ref.read(quotesProvider.notifier).removeMany(_picked);
    if (mounted) _exitSelect();
  }

  String _fmtDate(DateTime t) {
    final DateFormat df = DateFormat('M月 d日', 'zh_CN');
    return df.format(t);
  }
}

/// 多选模式顶栏 —— 对应 kit.css 的 `.topbar.select-bar`:
/// 左 ✕ 取消, 中「已选 N 句 / 选择金句」, 右「全选 / 取消全选」文字按钮。
class _SelectBar extends StatelessWidget {
  const _SelectBar({
    required this.count,
    required this.allPicked,
    required this.onCancel,
    required this.onToggleAll,
  });

  final int count;
  final bool allPicked;
  final VoidCallback onCancel;
  final VoidCallback onToggleAll;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final AppL10n l10n = AppL10n.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
      child: Row(
        children: <Widget>[
          XJKIconButton(
            icon: 'x',
            tooltip: l10n.actionClose,
            onPressed: onCancel,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              count > 0 ? l10n.selectedCount(count) : l10n.selectModeIdle,
              style: TextStyle(
                fontFamily: XJKTokens.serifDisplay,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: t.fg1,
              ),
            ),
          ),
          TextButton(
            onPressed: onToggleAll,
            child: Text(
              allPicked ? l10n.deselectAll : l10n.selectAll,
              style: TextStyle(
                fontFamily: XJKTokens.sansUi,
                fontSize: 14,
                color: t.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 底部批量「取出」栏 —— 对应 kit.css 的 `.action-bar` + `.btn.danger.block`。
class _RemoveActionBar extends StatelessWidget {
  const _RemoveActionBar({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: t.bgPage,
        border: Border(top: BorderSide(color: t.border1)),
      ),
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Material(
          color: t.danger,
          borderRadius: BorderRadius.circular(XJKTokens.radiusLg),
          child: InkWell(
            borderRadius: BorderRadius.circular(XJKTokens.radiusLg),
            onTap: enabled ? onPressed : null,
            child: Container(
              height: 50,
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const XJKIcon('trash-2', size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: XJKTokens.sansUi,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 多选模式下当前标签没有金句时的占位文案。
class _SelectEmpty extends StatelessWidget {
  const _SelectEmpty({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: XJKTokens.serifItalic,
            fontStyle: FontStyle.italic,
            fontSize: 14,
            color: t.fg3,
          ),
        ),
      ),
    );
  }
}

/// 显示 "今天的金句" 标签 —— l10n 化。
class _HelloHero extends StatelessWidget {
  const _HelloHero();

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        AppL10n.of(context).todayQuote,
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
    final AppL10n l10n = AppL10n.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            l10n.libraryEmptyTitle,
            style: TextStyle(
              fontFamily: XJKTokens.serifDisplay,
              fontSize: 22,
              color: t.fg1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.libraryEmptyBody,
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
          AppL10n.of(context).noMatchInTag(tag),
          style: TextStyle(color: t.fg3, fontFamily: XJKTokens.serifDisplay),
        ),
      ),
    );
  }
}
