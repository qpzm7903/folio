import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/tokens.dart';

/// 统一图标组件 —— 从 `assets/icons/<name>.svg` 加载本地 Lucide SVG。
///
/// 颜色: 默认走 `fg2`; 传 [color] 覆盖。
/// 尺寸: 默认 20 (inline), 底栏用 22, tab bar 用 24。
class XJKIcon extends StatelessWidget {
  const XJKIcon(this.name, {this.size = 20, this.color, super.key});

  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final Color resolved = color ?? t.fg2;
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(resolved, BlendMode.srcIn),
      placeholderBuilder: (BuildContext _) =>
          SizedBox(width: size, height: size),
    );
  }
}

/// 圆形透明的 icon button —— 36×36, 1.5px lucide stroke.
class XJKIconButton extends StatelessWidget {
  const XJKIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.size = 20,
    super.key,
  });

  final String icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Widget button = SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Center(
            child: XJKIcon(icon, size: size, color: color),
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
