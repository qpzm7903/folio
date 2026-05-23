import 'package:flutter/material.dart';

/// 桌面 / Web 上把内容收成一个最多 [maxWidth] 像素的居中竖列。
///
/// skill `README.md:167-169` 的硬规则: 桌面/平板 content max-width 640px,
/// "we are not a dashboard"。手机宽度本来就小, 这层约束自然不生效。
///
/// 不要包裹屏保级 (Display) 屏 —— 那个 quote 是有意 full-bleed 的。
class MaxWidthBody extends StatelessWidget {
  const MaxWidthBody({required this.child, this.maxWidth = 640, super.key});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
