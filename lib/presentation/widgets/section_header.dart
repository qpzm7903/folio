import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// 区段标题 —— 衬线大字 + 右侧斜体计数。对应 components.jsx 的 `SectionH`.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.count,
    this.suffix,
    super.key,
  });

  final String title;
  final int? count;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontFamily: XJKTokens.serifDisplay,
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: t.fg1,
            ),
          ),
          const Spacer(),
          if (count != null)
            Text(
              '$count 句',
              style: TextStyle(
                fontFamily: XJKTokens.serifItalic,
                fontStyle: FontStyle.italic,
                fontSize: 12,
                color: t.fg3,
              ),
            ),
          if (suffix != null)
            Text(
              suffix!,
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
