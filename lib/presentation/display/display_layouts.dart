import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/quote.dart';
import '../../domain/quote_clauses.dart';
import '../../theme/tokens.dart';
import 'display_layout.dart';

// 屏保全 9 版式 —— 对照 skill `display-layouts.jsx` + kit.css `.ds-*`。
// 页 / 竖 / 引 / 时 / 满 / 印 / 条 / 片 / 织 (v0.25.0 补齐后四款之外的
// 竖/引/条/织, 注册表顺序与设计源 LAYOUTS 一致)。
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

/// 版式底部「— 标签」落款 —— 满(Fullbleed) / 时(Lockscreen) 两版式共用。
///
/// 关闭"显示出处"或当前句无标签时返回空 list (不渲染); 两版式仅 [gap]/[fontSize]
/// 不同。v0.23.0 多标签后, 这里取首标签的逻辑只改这一处。
List<Widget> _attributionLine(
  DisplayLayoutData data, {
  required double gap,
  required double fontSize,
}) {
  if (!data.showAttribution || data.quote.tag.isEmpty) {
    return const <Widget>[];
  }
  return <Widget>[
    SizedBox(height: gap),
    Text(
      '— ${data.quote.tag}',
      style: _italicStyle(data.subColor, fontSize),
    ),
  ];
}

/// sans-ui 小号眉注/类目样式 —— kit.css `.cat` / `.ds-*-cat` 家族共用。
TextStyle _metaStyle(Color color, {double letterSpacing = 1.5}) => TextStyle(
      fontFamily: XJKTokens.sansUi,
      fontSize: 11,
      letterSpacing: letterSpacing,
      color: color,
    );

/// serif-italic 斜体小字 —— 落款/日期/品牌签名家族共用。
TextStyle _italicStyle(Color color, double fontSize) => TextStyle(
      fontFamily: XJKTokens.serifItalic,
      fontStyle: FontStyle.italic,
      fontSize: fontSize,
      color: color,
    );

/// 强调墨色 —— 照片背景用 leaf300 提亮, 否则主题 accent
/// (引 的引号 / 织 的编号共用, 对应 CSS `.on-photo` 覆写)。
Color _accentInk(DisplayLayoutData data) =>
    data.onPhoto ? data.tokens.leaf300 : data.tokens.accent;

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
    final TextStyle meta = _metaStyle(data.subColor);
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
          ..._attributionLine(data, gap: 28, fontSize: 15),
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
            style: _metaStyle(data.subColor),
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
          style: _italicStyle(data.subColor, 13),
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
        ..._attributionLine(data, gap: 12, fontSize: 13),
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
                style: _metaStyle(t.fg3),
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
              style: _italicStyle(t.fg3, 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 竖 Vertical — 竖排逐字, 右起分列; 立轴般的分隔线 + 类目 + 「金」印
// ─────────────────────────────────────────────────────────────
class VerticalLayout extends DisplayLayout {
  const VerticalLayout();

  @override
  String get key => 'vertical';
  @override
  String get nameZh => '竖';
  @override
  String get nameEn => 'Vertical';

  /// 竖排一段文字: 逐字成列, 列满 (maxHeight) 换列且新列在左
  /// (Wrap 垂直方向 + rtl), 对应 CSS `writing-mode: vertical-rl`。
  Widget _verticalText(
    String text, {
    required double fontSize,
    required double lineGap,
    required Color color,
    required String fontFamily,
    FontStyle? fontStyle,
  }) {
    return Wrap(
      direction: Axis.vertical,
      textDirection: TextDirection.rtl,
      alignment: WrapAlignment.center,
      spacing: fontSize * 0.12,
      runSpacing: lineGap,
      children: <Widget>[
        for (final String ch in text.characters)
          Text(
            ch,
            style: TextStyle(
              fontFamily: fontFamily,
              fontStyle: fontStyle,
              fontSize: fontSize,
              height: 1,
              color: color,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(DisplayLayoutData data) {
    final Quote q = data.quote;
    final XJKTokens t = data.tokens;
    final double fs = 26 * qScale(q.text);
    final Color line = data.subColor.withValues(alpha: 0.5);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Flexible(
            child: Center(
              child: FractionallySizedBox(
                heightFactor: 0.64,
                child: Center(
                  child: _verticalText(
                    q.text,
                    fontSize: fs,
                    lineGap: fs * 0.65,
                    color: data.textColor,
                    fontFamily: XJKTokens.serifDisplay,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 28),
          Container(width: 1, color: line),
          const SizedBox(width: 28),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              if (q.tag.isNotEmpty) ...<Widget>[
                _verticalText(
                  q.tag,
                  fontSize: 12,
                  lineGap: 12,
                  color: data.subColor,
                  fontFamily: XJKTokens.serifItalic,
                  fontStyle: FontStyle.italic,
                ),
                const SizedBox(height: 16),
              ],
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.bamboo500,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '金',
                  style: TextStyle(
                    fontFamily: XJKTokens.serifDisplay,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: t.fgOnAccent,
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 引 Pull-quote — 巨型起引号 + 正文 + 落款/收引号
// ─────────────────────────────────────────────────────────────
class PullLayout extends DisplayLayout {
  const PullLayout();

  @override
  String get key => 'pull';
  @override
  String get nameZh => '引';
  @override
  String get nameEn => 'Pull quote';

  @override
  Widget build(DisplayLayoutData data) {
    final Quote q = data.quote;
    final Color mark = _accentInk(data);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '“',
          style: TextStyle(
            fontFamily: XJKTokens.serifDisplay,
            fontSize: 120,
            height: 0.8,
            color: mark,
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              q.text,
              style: TextStyle(
                fontFamily: XJKTokens.serifDisplay,
                fontSize: 32 * qScale(q.text),
                height: 1.6,
                color: data.textColor,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: (data.showAttribution && q.tag.isNotEmpty)
                  ? Text(
                      q.tag,
                      style: _italicStyle(data.subColor, 14),
                    )
                  : const SizedBox.shrink(),
            ),
            Text(
              '”',
              style: TextStyle(
                fontFamily: XJKTokens.serifDisplay,
                fontSize: 56,
                height: 0.9,
                color: mark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 条 Ribbon — 通宽纸带, 即使照片背景也保持纸色 (这正是它的意义)
// ─────────────────────────────────────────────────────────────
class RibbonLayout extends DisplayLayout {
  const RibbonLayout();

  @override
  String get key => 'ribbon';
  @override
  String get nameZh => '条';
  @override
  String get nameEn => 'Ribbon';

  @override
  Widget build(DisplayLayoutData data) {
    final Quote q = data.quote;
    final XJKTokens t = data.tokens;
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 32),
        decoration: BoxDecoration(
          color: t.bgRaised,
          border: Border(
            top: BorderSide(color: t.border2),
            bottom: BorderSide(color: t.border2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (q.tag.isNotEmpty) ...<Widget>[
              Text(
                q.tag,
                textAlign: TextAlign.center,
                style: _italicStyle(t.accent, 13),
              ),
              const SizedBox(height: 14),
            ],
            Text(
              q.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: XJKTokens.serifDisplay,
                fontSize: 26 * qScale(q.text),
                height: 1.7,
                color: t.fg1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 织 Interleaved — 罗马数字编号 + 按标点分句, 发丝线间隔
// ─────────────────────────────────────────────────────────────
class InterleaveLayout extends DisplayLayout {
  const InterleaveLayout();

  @override
  String get key => 'interleave';
  @override
  String get nameZh => '织';
  @override
  String get nameEn => 'Interleaved';

  @override
  Widget build(DisplayLayoutData data) {
    final Quote q = data.quote;
    final double s = qScale(q.text);
    final List<String> parts = splitClauses(q.text);
    final Color rule = data.subColor.withValues(alpha: 0.5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          _roman(_editionNo(q.id)),
          style: TextStyle(
            fontFamily: XJKTokens.serifItalic,
            fontStyle: FontStyle.italic,
            fontSize: 72,
            height: 1,
            color: _accentInk(data),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int i = 0; i < parts.length; i++) ...<Widget>[
                  if (i > 0) Container(height: 1, color: rule),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12 * s),
                    child: Text(
                      parts[i],
                      style: TextStyle(
                        fontFamily: XJKTokens.serifDisplay,
                        fontSize: 24 * s,
                        height: 1.7,
                        color: data.textColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (q.tag.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              q.tag,
              style: _metaStyle(data.subColor, letterSpacing: 1.8),
            ),
          ),
      ],
    );
  }
}

/// 屏保版式注册表 —— display_screen 按下标循环。
/// 顺序对照 skill `display-layouts.jsx` 的 LAYOUTS 全 9 款 (v0.25.0)。
const List<DisplayLayout> kDisplayLayouts = <DisplayLayout>[
  PageLayout(),
  VerticalLayout(),
  PullLayout(),
  LockscreenLayout(),
  FullbleedLayout(),
  StampedLayout(),
  RibbonLayout(),
  CardLayout(),
  InterleaveLayout(),
];
