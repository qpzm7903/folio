import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import 'xjk_icon.dart';

/// SettingsGroup —— 一组 [SettingRow], 卡片化 + 内部分割线。
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(Divider(color: t.divider, height: 1, indent: 16));
      }
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: t.bgRaised,
        borderRadius: BorderRadius.circular(XJKTokens.radiusLg),
        border: Border.all(color: t.border1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
    );
  }
}

/// SettingRow —— 对应 components.jsx 的 `SettingRow`。
class SettingRow extends StatelessWidget {
  const SettingRow({
    required this.label,
    this.sub,
    this.value,
    this.toggle,
    this.onToggle,
    this.showChevron = true,
    this.onTap,
    super.key,
  });

  final String label;
  final String? sub;
  final String? value;
  final bool? toggle;
  final ValueChanged<bool>? onToggle;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return InkWell(
      onTap: toggle != null
          ? () => onToggle?.call(!(toggle ?? false))
          : onTap,
      borderRadius: BorderRadius.circular(XJKTokens.radiusLg),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: XJKTokens.serifDisplay,
                      fontSize: 15,
                      color: t.fg1,
                    ),
                  ),
                  if (sub != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      sub!,
                      style: TextStyle(
                        fontFamily: XJKTokens.sansUi,
                        fontSize: 12,
                        color: t.fg3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (value != null && toggle == null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  value!,
                  style: TextStyle(
                    fontFamily: XJKTokens.sansUi,
                    fontSize: 12,
                    color: t.fg3,
                  ),
                ),
              ),
            if (toggle != null)
              _Switch(value: toggle!, onChanged: onToggle ?? (_) {})
            else if (showChevron)
              XJKIcon('chevron-right', size: 14, color: t.fgMuted),
          ],
        ),
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  const _Switch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: XJKTokens.durFast,
        curve: XJKTokens.easePaper,
        width: 40,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? t.accent : t.paper300,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: XJKTokens.durFast,
          curve: XJKTokens.easePaper,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: t.bgRaised,
              borderRadius: BorderRadius.circular(999),
              boxShadow: t.shadow1,
            ),
          ),
        ),
      ),
    );
  }
}
