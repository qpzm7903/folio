import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/quote.dart';
import '../../theme/tokens.dart';
import '../providers.dart';
import '../widgets/max_width_body.dart';
import '../widgets/top_bar.dart';

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

    return MaxWidthBody(
      child: Column(
        children: <Widget>[
          const XJKTopBar(title: '小组件', subtitle: 'widgets'),
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
                  '三种尺寸 · 长按主屏 → 小组件, 拖动「小金库」到桌面。',
                  style: TextStyle(
                    fontFamily: XJKTokens.serifItalic,
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    color: t.fg3,
                  ),
                ),
                const SizedBox(height: 24),
                if (small != null) _SmallWidgetMock(quote: small),
                const SizedBox(height: 16),
                if (medium != null) _MediumWidgetMock(quote: medium),
                const SizedBox(height: 16),
                if (large != null) _LargeWidgetMock(quote: large),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallWidgetMock extends StatelessWidget {
  const _SmallWidgetMock({required this.quote});
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

class _MediumWidgetMock extends StatelessWidget {
  const _MediumWidgetMock({required this.quote});
  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Container(
      width: double.infinity,
      height: 160,
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
                fontSize: 16,
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

class _LargeWidgetMock extends StatelessWidget {
  const _LargeWidgetMock({required this.quote});
  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Container(
      width: double.infinity,
      height: 320,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[t.leaf700, const Color(0xFF2C3D27)],
        ),
        borderRadius: BorderRadius.circular(XJKTokens.radiusXl),
        boxShadow: t.shadow3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text(
                quote.text,
                maxLines: 7,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: XJKTokens.serifDisplay,
                  fontSize: 18,
                  height: 1.85,
                  color: Color(0xFFEDF2DC),
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
              color: const Color(0xFFEDF2DC).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
