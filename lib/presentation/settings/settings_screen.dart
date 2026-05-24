import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_version.dart';
import '../../core/router.dart';
import '../../data/settings_repository.dart';
import '../../theme/tokens.dart';
import '../providers.dart';
import '../widgets/max_width_body.dart';
import '../widgets/option_picker.dart';
import '../widgets/setting_row.dart';
import '../widgets/top_bar.dart';
import 'background_picker.dart';
import 'export_import_sheets.dart';

/// 频率选项的可读标签 —— 抽出来便于以后 i18n / 单测。
String cadenceLabel(int minutes) => '每 $minutes 分钟换一句';

/// settings 屏可选的频率档位 (分钟)。
const List<int> kCadenceChoices = <int>[1, 2, 3, 5, 15, 30, 60, 120, 240];

/// 设置 —— 对应 screens.jsx 的 `SettingsScreen`。
///
/// 5 个 section + 一个 footer。每 section 一个独立的私有 widget,
/// 加新 section (如 v0.7 "自定义背景图") 时只动一处。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// footer 上的版本标签 —— 从 [kAppVersion] (唯一可信源) 派生,
  /// `app_version_test.dart` 锁住跟 pubspec 一致。
  static const String _versionLabel = 'v $kAppVersion';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int quoteCount = ref.watch(quotesProvider).asData?.value.length ?? 0;

    return MaxWidthBody(
      child: Column(
        children: <Widget>[
          const XJKTopBar(title: '设置', subtitle: 'settings'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              children: <Widget>[
                const _RotationSection(),
                const _AppearanceSection(),
                const _TagsSection(),
                const _ImportExportSection(),
                const _AboutSection(),
                _VersionFooter(label: _versionLabel, quoteCount: quoteCount),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 一致风格的 section 大字标题。
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
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
}

/// 屏保 / 小组件: 频率 + 不重复 + 显示出处
class _RotationSection extends ConsumerWidget {
  const _RotationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings s = ref.watch(settingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _SectionLabel('屏保 / 小组件'),
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
            SettingRow(
              label: '背景图片',
              sub: backgroundSubLabel(ref, s.backgroundImagePath),
              value: s.backgroundImagePath == null ? '默认' : '自定义',
              onTap: () =>
                  showBackgroundPicker(context, ref, s.backgroundImagePath),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickCadence(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final int? next = await showOptionPicker<int>(
      context: context,
      current: current,
      options: <PickerOption<int>>[
        for (final int m in kCadenceChoices) (value: m, label: cadenceLabel(m)),
      ],
    );
    if (next != null) {
      await ref.read(settingsProvider.notifier).setCadenceMinutes(next);
    }
  }
}

/// 字体与外观: 主题 + (占位) 字号 / 字体。
class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings s = ref.watch(settingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _SectionLabel('字体与外观'),
        SettingsGroup(
          children: <Widget>[
            SettingRow(
              label: '主题',
              value: s.themeMode.displayLabel,
              onTap: () => _pickTheme(context, ref, s.themeMode),
            ),
            const SettingRow(label: '字号', value: '标准', showChevron: false),
            const SettingRow(
              label: '字体',
              value: 'Noto Serif SC',
              showChevron: false,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickTheme(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode current,
  ) async {
    final AppThemeMode? next = await showOptionPicker<AppThemeMode>(
      context: context,
      current: current,
      options: <PickerOption<AppThemeMode>>[
        for (final AppThemeMode m in AppThemeMode.values)
          (value: m, label: m.displayLabel),
      ],
    );
    if (next != null) {
      await ref.read(settingsProvider.notifier).setThemeMode(next);
    }
  }
}

/// 标签: 入口到 TagsScreen。
class _TagsSection extends ConsumerWidget {
  const _TagsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int favCount = ref.watch(favoritesProvider).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _SectionLabel('标签与收藏'),
        SettingsGroup(
          children: <Widget>[
            SettingRow(
              label: '标签管理',
              sub: '重命名 / 取下整组标签',
              onTap: () => context.push(FolioRoutes.tags),
            ),
            SettingRow(
              label: '我的收藏',
              sub: favCount > 0 ? '$favCount 句' : '在屏保里点 bookmark',
              onTap: () => context.push(FolioRoutes.favorites),
            ),
          ],
        ),
      ],
    );
  }
}

/// 导入与导出: 剪贴板 JSON 跨设备迁移。
class _ImportExportSection extends ConsumerWidget {
  const _ImportExportSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int quoteCount = ref.watch(quotesProvider).asData?.value.length ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _SectionLabel('导入与导出'),
        SettingsGroup(
          children: <Widget>[
            SettingRow(
              label: '导出金库',
              sub: '复制 JSON 到剪贴板, $quoteCount 句',
              onTap: () => showExportSheet(context, ref),
            ),
            SettingRow(
              label: '从剪贴板导入',
              sub: '粘贴之前导出的 JSON, 合并进现金库',
              onTap: () => showImportSheet(context, ref),
            ),
          ],
        ),
      ],
    );
  }
}

/// 关于。
class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionLabel('关于'),
        SettingsGroup(
          children: <Widget>[
            SettingRow(label: '小金库', sub: '一句话停一停', showChevron: false),
          ],
        ),
      ],
    );
  }
}

class _VersionFooter extends StatelessWidget {
  const _VersionFooter({required this.label, required this.quoteCount});

  final String label;
  final int quoteCount;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          '$label · 共 $quoteCount 句已入库',
          style: TextStyle(
            fontFamily: XJKTokens.serifItalic,
            fontStyle: FontStyle.italic,
            fontSize: 12,
            color: t.fgMuted,
          ),
        ),
      ),
    );
  }
}
