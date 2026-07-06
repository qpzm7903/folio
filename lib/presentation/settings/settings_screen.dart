import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_version.dart';
import '../../core/router.dart';
import '../../data/settings_repository.dart';
import '../../domain/tag_filter.dart';
import '../../theme/tokens.dart';
import '../providers.dart';
import '../widgets/max_width_body.dart';
import '../widgets/option_picker.dart';
import '../widgets/setting_row.dart';
import '../widgets/top_bar.dart';
import 'background_picker.dart';
import 'cadence_wheel_sheet.dart';
import 'export_import_sheets.dart';
import 'widget_color_picker.dart';

/// 设置 —— 对应 screens.jsx 的 `SettingsScreen`。
///
/// 5 个 section + 一个 footer。每 section 一个独立的私有 widget,

/// 枚举型设置行的通用选择流程 (v0.27.1 收敛 主题/字号/播放模式 三份样板):
/// 弹 OptionPicker → 选中即 apply。
Future<void> _pickEnum<T>(
  BuildContext context, {
  required T current,
  required List<T> values,
  required String Function(T) label,
  required Future<void> Function(T) apply,
}) async {
  final T? next = await showOptionPicker<T>(
    context: context,
    current: current,
    options: <PickerOption<T>>[
      for (final T v in values) (value: v, label: label(v)),
    ],
  );
  if (next != null) await apply(next);
}

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
          const XJKTopBar(title: '我的', subtitle: 'profile'),
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
        const _SectionLabel('小组件'),
        SettingsGroup(
          children: <Widget>[
            SettingRow(
              label: '自定义小组件',
              sub: '尺寸、频率、来源、字号',
              onTap: () => context.push(FolioRoutes.widgets),
            ),
            SettingRow(
              label: '更换频率',
              sub: '一句话停留多久',
              value: formatCadenceShort(s.cadenceMinutes),
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
            SettingRow(
              label: '小组件配色',
              sub: '桌面 widget 背景色',
              value: s.widgetColorTheme.displayLabel,
              onTap: () => _pickWidgetColor(context, ref, s.widgetColorTheme),
            ),
            SettingRow(
              label: '小组件播放模式',
              sub: '随机或按顺序换句',
              value: s.widgetPlayMode.displayLabel,
              onTap: () => _pickEnum<WidgetPlayMode>(
                context,
                current: s.widgetPlayMode,
                values: WidgetPlayMode.values,
                label: (WidgetPlayMode m) => m.displayLabel,
                apply: (WidgetPlayMode m) =>
                    ref.read(settingsProvider.notifier).setWidgetPlayMode(m),
              ),
            ),
            SettingRow(
              label: '来源标签',
              sub: '来自哪个标签',
              value: s.widgetSourceTag ?? kAllTagsLabel,
              onTap: () => _pickSourceTag(context, ref, s.widgetSourceTag),
            ),
          ],
        ),
      ],
    );
  }

  /// v0.29.0 来源标签 (设计源 widget-editor.jsx「来自哪个标签」ChipRow):
  /// 选项就是金库现有标签 (含「全部」「未分类」哨兵), 选「全部」存 null。
  Future<void> _pickSourceTag(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) async {
    final List<String> tags = ref.read(tagsProvider);
    final String? next = await showOptionPicker<String>(
      context: context,
      current: current ?? kAllTagsLabel,
      options: <PickerOption<String>>[
        for (final String t in tags) (value: t, label: t),
      ],
    );
    if (next != null) {
      await ref
          .read(settingsProvider.notifier)
          .setWidgetSourceTag(next == kAllTagsLabel ? null : next);
    }
  }

  Future<void> _pickWidgetColor(
    BuildContext context,
    WidgetRef ref,
    WidgetColorTheme current,
  ) async {
    final WidgetColorTheme? next = await showWidgetColorPicker(
      context: context,
      current: current,
    );
    if (next != null) {
      await ref.read(settingsProvider.notifier).setWidgetColorTheme(next);
    }
  }

  Future<void> _pickCadence(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final int? next = await showCadenceWheelSheet(
      context: context,
      currentMinutes: current,
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
              onTap: () => _pickEnum<AppThemeMode>(
                context,
                current: s.themeMode,
                values: AppThemeMode.values,
                label: (AppThemeMode m) => m.displayLabel,
                apply: (AppThemeMode m) =>
                    ref.read(settingsProvider.notifier).setThemeMode(m),
              ),
            ),
            SettingRow(
              label: '字号',
              value: s.fontScale.displayLabel,
              onTap: () => _pickEnum<AppFontScale>(
                context,
                current: s.fontScale,
                values: AppFontScale.values,
                label: (AppFontScale v) => v.displayLabel,
                apply: (AppFontScale v) =>
                    ref.read(settingsProvider.notifier).setFontScale(v),
              ),
            ),
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
              sub: '备份为 JSON / 纯文本, $quoteCount 句',
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
