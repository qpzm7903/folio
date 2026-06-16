import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/quote.dart';
import '../../theme/tokens.dart';
import 'display_layout.dart';

// 屏保精选 5 版式 —— 对照 skill `display-layouts.jsx` + kit.css `.ds-*`。
// 页 Page / 满 Full-bleed / 印 Stamped / 时 Lock screen / 片 Card on field。
// 字号统一 = 基准 × qScale(quote.text), 长短句自适应; 居中类版式用黄金比锚点。

const List<String> _cnNum = <String>[
  '',
  '一',
  '二',
  '三',
  '四',
  '五',
  '六',
  '七',
  '八',
  '九',
  '十',
  '十一',
  '十二',
];

/// 当月中文 + 品牌, 作页脚文学性落款 (如 `五月 · Folio`)。
String _footMeta() {
  final int m = DateTime.now().month;
  final String month = (m >= 1 && m <= 12) ? '${_cnNum[m]}月' : '小金库';
  return '$month · Folio';
}

/// 1..30 循环的罗马数字, 给 Page 版式当"版次"装饰。
String _roman(int n) {
  int x = ((n - 1) % 30) + 1;
  const List<(int, String)> table = <(int, String)>[
    (10, 'X'),
    (9, 'IX'),
    (5, 'V'),
    (4, 'IV'),
    (1, 'I'),
  ];
  final StringBuffer sb = StringBuffer();
  for (final (int v, String sym) in table) {
    while (x >= v) {
      sb.write(sym);
      x -= v;
    }
  }
  return sb.toString();
}

/// 由 id 稳定取一个 1..30 的小编号 (装饰用)。
int _editionNo(String id) => (id.hashCode.abs() % 30) + 1;

// ─────────────────────────────────────────────────────────────
// 页 Page — 像一页书: 页眉(版次/分隔/类目) · 黄金比正文 · 页脚
// ─────────────────────────────────────────────────────────────
class PageLayout extends DisplayLayout {
  const PageLayout();

  @override
  String get key => 'page';
  @override
  String get nameZh => '页';
  @override
  String get nameEn => 'Page';

  @override
  Widget build(DisplayLayoutData data) {
    final Quote q = data.quote;
    final Color line = data.subColor.withValues(alpha: 0.5);
    final TextStyle meta = TextStyle(
      fontFamily: XJKTokens.sansUi,
      fontSize: 11,
      letterSpacing: 1.5,
      color: data.subColor,
    );
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('no. ${_roman(_editionNo(q.id))}', style: meta),
            const SizedBox(width: 12),
            Expanded(child: Container(height: 1, color: line)),
            const SizedBox(width: 12),
            if (q.tag.isNotEmpty) Text(q.tag, style: meta),
          ],
        ),
        Expanded(
          child: goldenAnchor(
            Text(
              q.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: XJKTokens.serifDisplay,
                fontSize: 28 * qScale(q.text),
                height: XJKTokens.leadingLoose,
                color: data.textColor,
              ),
            ),
          ),
        ),
        Row(
          children: <Widget>[
            Container(width: 24, height: 1, color: line),
            const SizedBox(width: 12),
            Text(_footMeta(), style: meta),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 满 Full bleed — quote 即壁纸, 黄金比锚点
// ─────────────────────────────────────────────────────────────
class FullbleedLayout extends DisplayLayout {
  const FullbleedLayout();

  @override
  String get key => 'fullbleed';
  @override
  String get nameZh => '满';
  @override
  String get nameEn => 'Full bleed';

  @override
  Widget build(DisplayLayoutData data) {
    final Quote q = data.quote;
    return goldenAnchor(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            q.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: XJKTokens.serifDisplay,
              fontSize: XJKTokens.fsQuoteHero * qScale(q.text),
              height: XJKTokens.leadingLoose,
              color: data.textColor,
            ),
          ),
          if (data.showAttribution && q.tag.isNotEmpty) ...<Widget>[
            const SizedBox(height: 28),
            Text(
              '— ${q.tag}',
              style: TextStyle(
                fontFamily: XJKTokens.serifItalic,
                fontStyle: FontStyle.italic,
                fontSize: 15,
                color: data.subColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 印 Stamped — 首字巨型印章 + 余文流排
// ─────────────────────────────────────────────────────────────
class StampedLayout extends DisplayLayout {
  const StampedLayout();

  @override
  String get key => 'stamped';
  @override
  String get nameZh => '印';
  @override
  String get nameEn => 'Stamped';

  @override
  Widget build(DisplayLayoutData data) {
    final Quote q = data.quote;
    final String text = q.text;
    final String first = text.isNotEmpty ? text.characters.first : '金';
    final String rest = text.isNotEmpty ? text.substring(first.length) : '';
    final double s = qScale(text);
    final Color sealBg = data.onPhoto ? Colors.white24 : data.tokens.accent;
    final Color sealFg = data.onPhoto ? data.textColor : data.tokens.fgOnAccent;
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (q.tag.isNotEmpty)
          Text(
            q.tag,
            style: TextStyle(
              fontFamily: XJKTokens.sansUi,
              fontSize: 11,
              letterSpacing: 1.5,
              color: data.subColor,
            ),
          ),
        Expanded(
          child: Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: sealBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    first,
                    style: TextStyle(
                      fontFamily: XJKTokens.serifDisplay,
                      fontSize: 40,
                      height: 1,
                      color: sealFg,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    rest,
                    style: TextStyle(
                      fontFamily: XJKTokens.serifDisplay,
                      fontSize: 24 * s,
                      height: XJKTokens.leadingSnug,
                      color: data.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Text(
          _footMeta(),
          style: TextStyle(
            fontFamily: XJKTokens.serifItalic,
            fontStyle: FontStyle.italic,
            fontSize: 13,
            color: data.subColor,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 时 Lock screen — 时钟 + 日期为主, quote 作题注 (实时走字)
// ─────────────────────────────────────────────────────────────
class LockscreenLayout extends DisplayLayout {
  const LockscreenLayout();

  @override
  String get key => 'lockscreen';
  @override
  String get nameZh => '时';
  @override
  String get nameEn => 'Lock screen';

  @override
  Widget build(DisplayLayoutData data) => _LockscreenBody(data: data);
}

class _LockscreenBody extends StatefulWidget {
  const _LockscreenBody({required this.data});

  final DisplayLayoutData data;

  @override
  State<_LockscreenBody> createState() => _LockscreenBodyState();
}

class _LockscreenBodyState extends State<_LockscreenBody> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // 每 20s 刷新一次时钟显示 (不必精确到秒)。
    _ticker = Timer.periodic(
      const Duration(seconds: 20),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _hhmm(DateTime now) => '${now.hour.toString().padLeft(2, '0')}:'
      '${now.minute.toString().padLeft(2, '0')}';

  String _date(DateTime now) {
    const List<String> week = <String>['一', '二', '三', '四', '五', '六', '日'];
    final String w = week[(now.weekday - 1).clamp(0, 6)];
    return '${now.month}月${now.day}日 · 周$w';
  }

  @override
  Widget build(BuildContext context) {
    final DisplayLayoutData data = widget.data;
    final Quote q = data.quote;
    final DateTime now = DateTime.now();
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 24),
        Text(
          _hhmm(now),
          style: TextStyle(
            fontFamily: XJKTokens.serifDisplay,
            fontSize: 64,
            height: 1.05,
            color: data.textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _date(now),
          style: TextStyle(
            fontFamily: XJKTokens.sansUi,
            fontSize: 13,
            color: data.subColor,
          ),
        ),
        const Spacer(),
        Text(
          q.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: XJKTokens.serifDisplay,
            fontSize: 20 * qScale(q.text),
            height: XJKTokens.leadingLoose,
            color: data.textColor,
          ),
        ),
        if (data.showAttribution && q.tag.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            '— ${q.tag}',
            style: TextStyle(
              fontFamily: XJKTokens.serifItalic,
              fontStyle: FontStyle.italic,
              fontSize: 13,
              color: data.subColor,
            ),
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 片 Card on field — 纸卡浮在纹理场上, 落款
// ─────────────────────────────────────────────────────────────
class CardLayout extends DisplayLayout {
  const CardLayout();

  @override
  String get key => 'card';
  @override
  String get nameZh => '片';
  @override
  String get nameEn => 'Card on field';

  @override
  Widget build(DisplayLayoutData data) {
    final Quote q = data.quote;
    final XJKTokens t = data.tokens;
    final Color cardBg =
        data.onPhoto ? t.bgRaised.withValues(alpha: 0.92) : t.bgCard;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.border1),
          boxShadow: t.shadow2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (q.tag.isNotEmpty)
              Text(
                q.tag,
                style: TextStyle(
                  fontFamily: XJKTokens.sansUi,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: t.fg3,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              q.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: XJKTokens.serifDisplay,
                fontSize: 22 * qScale(q.text),
                height: XJKTokens.leadingLoose,
                color: t.fg1,
              ),
            ),
            const SizedBox(height: 16),
            Container(width: 28, height: 1, color: t.border2),
            const SizedBox(height: 12),
            Text(
              '小金库 · Folio',
              style: TextStyle(
                fontFamily: XJKTokens.serifItalic,
                fontStyle: FontStyle.italic,
                fontSize: 12,
                color: t.fg3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 屏保版式注册表 —— display_screen 按下标循环。顺序对照 skill 精选 5 版式。
const List<DisplayLayout> kDisplayLayouts = <DisplayLayout>[
  PageLayout(),
  FullbleedLayout(),
  StampedLayout(),
  LockscreenLayout(),
  CardLayout(),
];
