import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// BottomSheet 正文骨架 —— 收敛 导出/JSON导入/批量导入/标签改名 4 个 sheet
/// 逐字节相同的头部: viewInsets 让位 padding + 标题 + 副标题 + 间距。
///
/// cadence 滚轮 sheet 是设计源指定的视觉变体 (透明背景 + 自绘 grabber),
/// 有意不用本组件。
class XJKSheetBody extends StatelessWidget {
  const XJKSheetBody({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.scrollable = false,
  });

  final String title;
  final String subtitle;

  /// 头部下方的内容区, 布局同原有 sheet: Column(min, stretch)。
  final List<Widget> children;

  /// 内容可能超过小屏可视高度时 (如批量导入的勾选列表) 包一层滚动,
  /// 避免键盘弹起时 RenderFlex overflow。
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final MediaQueryData media = MediaQuery.of(context);
    final Widget column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontFamily: XJKTokens.serifDisplay,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: t.fg1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: XJKTokens.serifDisplay,
            fontSize: 14,
            color: t.fg3,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + media.viewInsets.bottom),
      child: scrollable ? SingleChildScrollView(child: column) : column,
    );
  }
}
