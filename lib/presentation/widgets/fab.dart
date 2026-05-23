import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import 'xjk_icon.dart';

/// 浮动操作按钮 —— matcha 实心圆, 唯一的 accent 色用法 (每屏至多 1 个).
class XJKFab extends StatelessWidget {
  const XJKFab({
    required this.onPressed,
    this.icon = 'plus',
    this.tooltip,
    super.key,
  });

  final VoidCallback? onPressed;
  final String icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final Widget body = SizedBox(
      width: 56,
      height: 56,
      child: Material(
        color: t.accent,
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: XJKIcon(icon, size: 22, color: t.fgOnAccent),
          ),
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: t.shadow2,
      ),
      child: tooltip == null ? body : Tooltip(message: tooltip!, child: body),
    );
  }
}
