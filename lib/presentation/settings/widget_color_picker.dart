import 'package:flutter/material.dart';

import '../../data/widget_color_theme.dart';
import '../../theme/tokens.dart';

/// 桌面小组件配色 BottomSheet, 6 个色卡单选 (v0.21.0 从 3 个扩到 6 个,
/// 对照设计系统六主题)。
///
/// 视觉跟 option_picker 同样的 ListTile + ✓ 路线, 但加 leading 色卡圆点
/// 让用户能直观看颜色对比 (纯文字标签表达力不够)。
Future<WidgetColorTheme?> showWidgetColorPicker({
  required BuildContext context,
  required WidgetColorTheme current,
}) {
  return showModalBottomSheet<WidgetColorTheme>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext ctx) {
      final XJKTokens t = XJKTheme.of(ctx);
      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text(
                  '小组件配色',
                  style: TextStyle(
                    fontFamily: XJKTokens.serifDisplay,
                    fontSize: 17,
                    color: t.fg1,
                  ),
                ),
              ),
              for (final WidgetColorTheme c in WidgetColorTheme.values)
                ListTile(
                  leading: _Swatch(theme: c, t: t),
                  title: Text(
                    c.displayLabel,
                    style: const TextStyle(fontFamily: XJKTokens.serifDisplay),
                  ),
                  subtitle: Text(
                    c.displaySub,
                    style: TextStyle(
                      fontFamily: XJKTokens.serifItalic,
                      fontStyle: FontStyle.italic,
                      color: t.fgMuted,
                      fontSize: 12,
                    ),
                  ),
                  trailing: current == c ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.of(ctx).pop(c),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.theme, required this.t});

  final WidgetColorTheme theme;
  final XJKTokens t;

  /// 色卡圆点用各主题的 paper-100 (卡片底色), 让用户直观看卡片背景色。
  /// 委托 [XJKTokens.forId], 消除 magic Color 字面量。
  Color get _color => XJKTokens.forId(theme.xjkThemeId).paper100;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
        border: Border.all(color: t.border1),
      ),
    );
  }
}
