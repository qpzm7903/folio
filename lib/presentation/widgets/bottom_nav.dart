import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import 'xjk_icon.dart';

enum XJKNavTab { library, display, widgetsTab, settings }

/// 底部导航 —— 对应 components.jsx 的 `BottomNav`。
/// 4 项: 金库 / 屏保 / 组件 / 设置。
class XJKBottomNav extends StatelessWidget {
  const XJKBottomNav({
    required this.current,
    required this.onChanged,
    super.key,
  });

  final XJKNavTab current;
  final ValueChanged<XJKNavTab> onChanged;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(tab: XJKNavTab.library, icon: 'book-open', label: '金库'),
    _NavItem(tab: XJKNavTab.display, icon: 'sparkles', label: '屏保'),
    _NavItem(tab: XJKNavTab.widgetsTab, icon: 'grid-2x2', label: '组件'),
    _NavItem(tab: XJKNavTab.settings, icon: 'settings', label: '设置'),
  ];

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color barColor = isDark
        ? t.paper100.withValues(alpha: 0.85)
        : t.paper50.withValues(alpha: 0.85);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: barColor,
            border: Border(top: BorderSide(color: t.border1)),
          ),
          padding: EdgeInsets.fromLTRB(
            16,
            6,
            16,
            6 + MediaQuery.of(context).padding.bottom,
          ),
          child: Row(
            children: <Widget>[
              for (final _NavItem it in _items)
                Expanded(
                  child: _NavButton(
                    item: it,
                    active: it.tab == current,
                    onTap: () => onChanged(it.tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.tab, required this.icon, required this.label});
  final XJKNavTab tab;
  final String icon;
  final String label;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final Color color = active ? t.fg1 : t.fg3;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            XJKIcon(item.icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: XJKTokens.sansUi,
                fontSize: 10,
                letterSpacing: 0.4,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
