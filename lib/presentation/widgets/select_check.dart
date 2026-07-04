import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import 'xjk_icon.dart';

/// 圆形勾选框 —— 对应 kit.css 的 `.qcheck` / `.qcheck.on`。
///
/// v0.24.1 从 quote_card 的私有 `_SelectCheck` 抽出共享:
/// 金库多选卡片与批量导入勾选行用同一份视觉, 避免复制漂移。
class XJKSelectCheck extends StatelessWidget {
  const XJKSelectCheck({required this.on, super.key});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return AnimatedContainer(
      duration: XJKTokens.durFast,
      curve: XJKTokens.easePaper,
      width: 22,
      height: 22,
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
