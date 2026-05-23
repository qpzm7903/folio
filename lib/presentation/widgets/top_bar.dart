import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import 'xjk_icon.dart';

/// 顶部栏 —— 对应 components.jsx 的 TopBar:
/// - 衬线标题 + 斜体英文副标题
/// - 右侧最多 3 个 icon 按钮
class XJKTopBar extends StatelessWidget {
  const XJKTopBar({
    required this.title,
    this.subtitle,
    this.actions = const <XJKTopBarAction>[],
    this.leading,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<XJKTopBarAction> actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 12, 14),
      child: Row(
        children: <Widget>[
          if (leading != null) ...<Widget>[leading!, const SizedBox(width: 8)],
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: XJKTokens.serifDisplay,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: t.fg1,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(width: 8),
                  Text(
                    subtitle!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: XJKTokens.serifItalic,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color: t.fg3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          for (final XJKTopBarAction a in actions)
            XJKIconButton(
              icon: a.icon,
              onPressed: a.onPressed,
              tooltip: a.label,
            ),
        ],
      ),
    );
  }
}

class XJKTopBarAction {
  const XJKTopBarAction({required this.icon, this.label, this.onPressed});

  final String icon;
  final String? label;
  final VoidCallback? onPressed;
}
