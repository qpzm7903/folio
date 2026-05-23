import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/tokens.dart';
import '../../data/settings_repository.dart';
import '../providers.dart';
import '../widgets/setting_row.dart';
import '../widgets/top_bar.dart';

/// 设置 —— 对应 screens.jsx 的 `SettingsScreen`.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final XJKTokens t = XJKTheme.of(context);
    final AppSettings s = ref.watch(settingsProvider);
    final int quoteCount =
        ref.watch(quotesProvider).asData?.value.length ?? 0;

    String themeLabel;
    switch (s.themeMode) {
      case AppThemeMode.system:
        themeLabel = '跟随系统';
        break;
      case AppThemeMode.paper:
        themeLabel = '青纸 · Paper';
        break;
      case AppThemeMode.night:
        themeLabel = '林夜 · Forest';
        break;
    }

    return Column(
      children: <Widget>[
        const XJKTopBar(title: '设置', subtitle: 'settings'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            children: <Widget>[
              _sectionLabel(context, '屏保 / 小组件'),
              SettingsGroup(
                children: <Widget>[
                  SettingRow(
                    label: '更换频率',
                    sub: '一句话停留多久',
                    value: '${s.cadenceMinutes} 分钟',
                    onTap: () => _pickCadence(context, ref, s.cadenceMinutes),
                  ),
                  SettingRow(
                    label: '不重复轮播',
                    sub: '所有句子轮过一次才再出现',
                    toggle: s.shuffleNoRepeat,
                    showChevron: false,
                    onToggle: (bool v) =>
                        ref.read(settingsProvider.notifier).setShuffleNoRepeat(v),
                  ),
                  SettingRow(
                    label: '显示出处',
                    sub: 'quote attribution',
                    toggle: s.showAttribution,
                    showChevron: false,
                    onToggle: (bool v) =>
                        ref.read(settingsProvider.notifier).setShowAttribution(v),
                  ),
                ],
              ),
              _sectionLabel(context, '字体与外观'),
              SettingsGroup(
                children: <Widget>[
                  SettingRow(
                    label: '主题',
                    value: themeLabel,
                    onTap: () => _pickTheme(context, ref, s.themeMode),
                  ),
                  const SettingRow(
                    label: '字号',
                    value: '标准',
                    showChevron: false,
                  ),
                  const SettingRow(
                    label: '字体',
                    value: 'Noto Serif SC',
                    showChevron: false,
                  ),
                ],
              ),
              _sectionLabel(context, '关于'),
              const SettingsGroup(
                children: <Widget>[
                  SettingRow(
                    label: '小金库',
                    sub: '一句话停一停',
                    showChevron: false,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'v 0.1 · 共 $quoteCount 句已入库',
                    style: TextStyle(
                      fontFamily: XJKTokens.serifItalic,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color: t.fgMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    final XJKTokens t = XJKTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 0, 10),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: XJKTokens.serifDisplay,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: t.fg1,
        ),
      ),
    );
  }

  Future<void> _pickTheme(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode current,
  ) async {
    final AppThemeMode? next = await showModalBottomSheet<AppThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final (AppThemeMode, String) item in const <(
                AppThemeMode,
                String
              )>[
                (AppThemeMode.system, '跟随系统'),
                (AppThemeMode.paper, '青纸 · Paper'),
                (AppThemeMode.night, '林夜 · Forest'),
              ])
                ListTile(
                  title: Text(
                    item.$2,
                    style: const TextStyle(fontFamily: XJKTokens.serifDisplay),
                  ),
                  trailing: current == item.$1 ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.of(ctx).pop(item.$1),
                ),
            ],
          ),
        );
      },
    );
    if (next != null) {
      await ref.read(settingsProvider.notifier).setThemeMode(next);
    }
  }

  Future<void> _pickCadence(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final int? next = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final int m in <int>[5, 15, 30, 60, 120, 240])
                ListTile(
                  title: Text(
                    '每 $m 分钟换一句',
                    style: const TextStyle(fontFamily: XJKTokens.serifDisplay),
                  ),
                  trailing: current == m ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.of(ctx).pop(m),
                ),
            ],
          ),
        );
      },
    );
    if (next != null) {
      await ref.read(settingsProvider.notifier).setCadenceMinutes(next);
    }
  }
}
