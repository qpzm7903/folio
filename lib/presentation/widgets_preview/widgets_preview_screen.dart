import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../data/quote.dart';
import '../../theme/tokens.dart';
import '../providers.dart';
import '../widgets/max_width_body.dart';
import '../widgets/top_bar.dart';
import '../widgets/xjk_icon.dart';

/// 组件预览屏 —— 真实 Android widget 在 v0.11.0 (L07) 已落地,
/// iOS 在 v0.12.0 (L08) 已落地; 这屏保留为"主屏添加引导 + 视觉预览"。
///
/// v0.15.4 Issue #6: 视觉跟 Android widget 同步去掉 "金" 印, 出处改为右下角。
class WidgetsPreviewScreen extends ConsumerWidget {
  const WidgetsPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final XJKTokens t = XJKTheme.of(context);
    final AsyncValue<List<Quote>> async = ref.watch(quotesProvider);
    final List<Quote> quotes = async.value ?? const <Quote>[];
    final Quote? small = quotes.isNotEmpty ? quotes[0] : null;
    final Quote? medium = quotes.length > 1 ? quotes[1] : small;
    final Quote? large = quotes.length > 2 ? quotes[2] : small;

    return Scaffold(
      backgroundColor: t.bgPage,
      body: SafeArea(
        child: MaxWidthBody(
          child: Column(
            children: <Widget>[
              XJKTopBar(
                title: '小组件',
                subtitle: 'widgets',
                leading: XJKIconButton(
                  icon: 'chevron-left',
                  tooltip: '返回',
                  onPressed: () {
                    // 组件预览屏是从「我的」push 进来的, 优先 pop 回我的;
                    // 兜底 go 回首页 (顶层 tab)。
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(FolioRoutes.display);
                    }
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  children: <Widget>[
                    Text(
                      '把金句放到主屏。',
                      style: TextStyle(
                        fontFamily: XJKTokens.serifDisplay,
                        fontSize: 22,
                        color: t.fg1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '2×2 / 2×4 / 4×4 · 长按主屏添加「小金库」卡片。',
                      style: TextStyle(
                        fontFamily: XJKTokens.serifItalic,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        color: t.fg3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (small != null) _WidgetMock2x2(quote: small),
                    const SizedBox(height: 16),
                    if (medium != null) _WidgetMock2x4(quote: medium),
                    const SizedBox(height: 16),
                    if (large != null) _WidgetMock4x4(quote: large),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WidgetMock2x2 extends StatelessWidget {
  const _WidgetMock2x2({required this.quote});
  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Container(
      width: 160,
      height: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.bgRaised,
        borderRadius: BorderRadius.circular(XJKTokens.radiusXl),
        border: Border.all(color: t.border1),
        boxShadow: t.shadow2,
      ),
      child: Center(
        child: Text(
          quote.text,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: XJKTokens.serifDisplay,
            fontSize: 12.5,
            height: 1.6,
            color: t.fg1,
          ),
        ),
      ),
    );
  }
}

class _WidgetMock2x4 extends StatelessWidget {
  const _WidgetMock2x4({required this.quote});
  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    // 2×4 横长条: 宽满, 高度按 2:4 比例缩放 (卡片格 2 行高)。
    return Container(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.bgRaised,
        borderRadius: BorderRadius.circular(XJKTokens.radiusXl),
        border: Border.all(color: t.border1),
        boxShadow: t.shadow2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Text(
              quote.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: XJKTokens.serifDisplay,
                fontSize: 15,
                height: 1.7,
                color: t.fg1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '— ${quote.tag}',
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: XJKTokens.serifItalic,
              fontStyle: FontStyle.italic,
              fontSize: 12,
              color: t.fg3,
            ),
          ),
        ],
      ),
    );
  }
}

class _WidgetMock4x4 extends StatelessWidget {
  const _WidgetMock4x4({required this.quote});
  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    // 4×4 大方块: 宽满, 高度 = 宽 (正方形, 卡片格 4 行高)。
    return Container(
      width: double.infinity,
      height: 340,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: t.bgRaised,
        borderRadius: BorderRadius.circular(XJKTokens.radiusXl),
        border: Border.all(color: t.border1),
        boxShadow: t.shadow3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text(
                quote.text,
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: XJKTokens.serifDisplay,
                  fontSize: 18,
                  height: 1.85,
                  color: t.fg1,
                ),
              ),
            ),
          ),
          Text(
            '— ${quote.tag}',
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: XJKTokens.serifItalic,
              fontStyle: FontStyle.italic,
              fontSize: 12,
              color: t.fg3,
            ),
          ),
        ],
      ),
    );
  }
}
