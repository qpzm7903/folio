import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/quote.dart';
import '../../theme/tokens.dart';
import '../providers.dart';
import '../widgets/max_width_body.dart';
import '../widgets/quote_card.dart';
import '../widgets/section_header.dart';
import '../widgets/top_bar.dart';
import '../widgets/xjk_icon.dart';

/// 收藏列表屏 —— v0.14.0 (兑现 v0.13.3 修 Issue #4 时留的 promise)。
///
/// 把 Display 屏 bookmark 按钮收藏过的 quote 列出来; 视觉沿用
/// `LibraryScreen` 的卡片风格 + 按收藏顺序倒序展示 (新的在前)。
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final XJKTokens t = XJKTheme.of(context);
    final AsyncValue<List<Quote>> async = ref.watch(quotesProvider);
    final Set<String> favIds = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: t.bgPage,
      body: SafeArea(
        child: MaxWidthBody(
          child: Column(
            children: <Widget>[
              XJKTopBar(
                title: '收藏',
                subtitle: 'favorites',
                leading: XJKIconButton(
                  icon: 'chevron-left',
                  tooltip: '返回',
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/library');
                    }
                  },
                ),
              ),
              Expanded(
                child: async.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (Object e, StackTrace _) => Center(
                    child: Text('$e', style: TextStyle(color: t.danger)),
                  ),
                  data: (List<Quote> quotes) {
                    final List<Quote> favorites = quotes
                        .where((Quote q) => favIds.contains(q.id))
                        .toList(growable: false);
                    if (favorites.isEmpty) {
                      return const _FavoritesEmpty();
                    }
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      children: <Widget>[
                        SectionHeader(
                          title: '你收藏过的',
                          count: favorites.length,
                        ),
                        const SizedBox(height: 8),
                        for (final Quote q in favorites) ...<Widget>[
                          QuoteCard(
                            quote: q.text,
                            source: q.tag.isEmpty ? null : q.tag,
                            date: DateFormat(
                              'M月 d日',
                              'zh_CN',
                            ).format(q.createdAt),
                            onTap: () => context.push('/editor/${q.id}'),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
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
}

class _FavoritesEmpty extends StatelessWidget {
  const _FavoritesEmpty();

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          '还没收藏过句子。\n在屏保里点 bookmark 试试。',
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
