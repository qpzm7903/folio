import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// QuoteCard —— 对应 components.jsx 的 `QuoteCard`。
///
/// 两个 variant:
/// - `default`: 浅色卡, 用纸张色 + 1px border
/// - `dark`: 深绿渐变卡, "今日金句" 单独突出
class QuoteCard extends StatelessWidget {
  const QuoteCard({
    required this.quote,
    this.source,
    this.date,
    this.variant = QuoteCardVariant.normal,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  final String quote;
  final String? source;
  final String? date;
  final QuoteCardVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final bool isDark = variant == QuoteCardVariant.featured;

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
            color: t.bgRaised,
            borderRadius: BorderRadius.circular(XJKTokens.radiusLg),
            border: Border.all(color: t.border1),
          );

    final Color textColor = isDark ? const Color(0xFFEDF2DC) : t.fg1;
    final Color metaColor = isDark
        ? const Color(0xFFEDF2DC).withValues(alpha: 0.7)
        : t.fg3;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(XJKTokens.radiusLg),
          onTap: onTap,
          onLongPress: onLongPress,
          child: AnimatedContainer(
            duration: XJKTokens.durFast,
            curve: XJKTokens.easePaper,
            decoration: decoration,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Column(
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
                    if (source != null && source!.isNotEmpty)
                      Text(
                        source!,
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
            ),
          ),
        ),
      ),
    );
  }
}

enum QuoteCardVariant { normal, featured }
