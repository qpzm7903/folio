import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import 'xjk_icon.dart';

/// QuoteCard —— 对应 components.jsx 的 `QuoteCard`。
///
/// 两个 variant:
/// - `default`: 浅色卡, 用纸张色 + 1px border
/// - `dark`: 深绿渐变卡, "今日金句" 单独突出
///
/// 多选模式 (`selectable`): 左侧多出一个圆形勾选框, 点卡片即切换选中
/// (走 [onToggle], 此时 [onTap]/[onLongPress] 不生效); 选中态描边换成
/// accent, 底色叠一层 8% accent。
class QuoteCard extends StatelessWidget {
  const QuoteCard({
    required this.quote,
    this.tag,
    this.date,
    this.variant = QuoteCardVariant.normal,
    this.onTap,
    this.onLongPress,
    this.selectable = false,
    this.selected = false,
    this.onToggle,
    super.key,
  });

  final String quote;

  /// 卡片副信息 (meta 行左侧) —— 当前承载金句的标签 (`Quote.tag`)。
  /// v0.23.0 多标签后将改为渲染标签列表。
  final String? tag;
  final String? date;
  final QuoteCardVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 多选模式开关。开启后整卡点击切换选中, 左侧显示勾选框。
  final bool selectable;
  final bool selected;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final bool isDark =
        variant == QuoteCardVariant.featured && !selectable;

    final BoxDecoration decoration = isDark
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(XJKTokens.radiusLg),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[t.leaf700, const Color(0xFF2C3D27)],
            ),
            boxShadow: t.shadow2,
          )
        : BoxDecoration(
            color: selected
                ? Color.alphaBlend(
                    t.accent.withValues(alpha: 0.08),
                    t.bgRaised,
                  )
                : t.bgRaised,
            borderRadius: BorderRadius.circular(XJKTokens.radiusLg),
            border: Border.all(color: selected ? t.accent : t.border1),
          );

    final Color textColor = isDark ? const Color(0xFFEDF2DC) : t.fg1;
    final Color metaColor =
        isDark ? const Color(0xFFEDF2DC).withValues(alpha: 0.7) : t.fg3;

    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          quote,
          style: TextStyle(
            fontFamily: XJKTokens.serifDisplay,
            fontSize: isDark ? 22 : 18,
            height: 1.75,
            color: textColor,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (tag != null && tag!.isNotEmpty)
              Text(
                tag!,
                style: TextStyle(
                  fontFamily: XJKTokens.serifItalic,
                  fontStyle: FontStyle.italic,
                  fontSize: 11,
                  color: metaColor,
                ),
              )
            else
              const SizedBox.shrink(),
            if (date != null)
              Text(
                date!,
                style: TextStyle(
                  fontFamily: XJKTokens.sansUi,
                  fontSize: 11,
                  color: metaColor,
                  letterSpacing: 0.2,
                ),
              ),
          ],
        ),
      ],
    );

    final Widget content = selectable
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _SelectCheck(on: selected),
              const SizedBox(width: 12),
              Expanded(child: body),
            ],
          )
        : body;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(XJKTokens.radiusLg),
          onTap: selectable ? onToggle : onTap,
          onLongPress: selectable ? null : onLongPress,
          child: AnimatedContainer(
            duration: XJKTokens.durFast,
            curve: XJKTokens.easePaper,
            decoration: decoration,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// 圆形勾选框 —— 对应 kit.css 的 `.qcheck` / `.qcheck.on`。
class _SelectCheck extends StatelessWidget {
  const _SelectCheck({required this.on});
  final bool on;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return AnimatedContainer(
      duration: XJKTokens.durFast,
      curve: XJKTokens.easePaper,
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? t.accent : Colors.transparent,
        border: Border.all(
          color: on ? t.accent : t.border2,
          width: 1.5,
        ),
      ),
      child: on
          ? Center(child: XJKIcon('check', size: 13, color: t.fgOnAccent))
          : null,
    );
  }
}

enum QuoteCardVariant { normal, featured }
