/// 全局设置 model 与对应枚举。
///
/// 不耦合 [SharedPreferences]; IO 适配在 `settings_repository.dart` 里。
library;

import '../theme/xjk_theme_id.dart';
import 'widget_color_theme.dart';
import 'widget_play_mode.dart';

export 'widget_color_theme.dart' show WidgetColorTheme;
export 'widget_play_mode.dart' show WidgetPlayMode, WidgetPlayModeLabel;

/// 主题设置 —— `system` (跟随系统) + 六个具体主题 (晨→昏顺序, 对齐
/// [XJKThemeId])。枚举值新增向后兼容: 旧持久化的 system/paper/night 仍可解码。
enum AppThemeMode { system, paper, celadon, moonwhite, cinnabar, night, dai }

extension AppThemeModeLabel on AppThemeMode {
  /// 用户可见标签 —— 中文为主, 形如 `青纸 · Tea Paper`。
  /// 具体主题委托 [XJKThemeId.label] (单一可信源), 不再各自硬编码。
  String get displayLabel => themeId?.label ?? '跟随系统';
}

extension AppThemeModeThemeId on AppThemeMode {
  /// 显式选定的主题标识; `system` (跟随系统) 返回 `null`, 由调用方按
  /// 平台亮度在 [XJKThemeId.lightDefault] / [XJKThemeId.darkDefault] 间取默认。
  ///
  /// 这是"主题设置"到"主题注册表"的唯一映射点。
  XJKThemeId? get themeId {
    switch (this) {
      case AppThemeMode.system:
        return null;
      case AppThemeMode.paper:
        return XJKThemeId.paper;
      case AppThemeMode.celadon:
        return XJKThemeId.celadon;
      case AppThemeMode.moonwhite:
        return XJKThemeId.moonwhite;
      case AppThemeMode.cinnabar:
        return XJKThemeId.cinnabar;
      case AppThemeMode.night:
        return XJKThemeId.night;
      case AppThemeMode.dai:
        return XJKThemeId.dai;
    }
  }
}

/// 字号档位 (v0.27.0) —— 设计源 SettingsScreen「字号」行的落地,
/// 经 MediaQuery textScaler 全局生效 (与系统缩放叠乘)。
enum AppFontScale { standard, large, xlarge }

extension AppFontScaleLabel on AppFontScale {
  String get displayLabel {
    switch (this) {
      case AppFontScale.standard:
        return '标准';
      case AppFontScale.large:
        return '大';
      case AppFontScale.xlarge:
        return '特大';
    }
  }

  /// 文本缩放因子。
  double get factor {
    switch (this) {
      case AppFontScale.standard:
        return 1.0;
      case AppFontScale.large:
        return 1.15;
      case AppFontScale.xlarge:
        return 1.3;
    }
  }
}

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.shuffleNoRepeat,
    required this.showAttribution,
    required this.cadenceMinutes,
    required this.backgroundImagePath,
    required this.widgetColorTheme,
    required this.displayLayoutKey,
    required this.widgetPlayMode,
    required this.fontScale,
    required this.widgetSourceTag,
  });

  /// 屏保版式默认 key (= skill 精选 5 版式的首项 页 Page)。放在 data 层常量
  /// 避免持久化层依赖 presentation 层的 kDisplayLayouts。
  static const String defaultDisplayLayoutKey = 'page';

  final AppThemeMode themeMode;
  final bool shuffleNoRepeat;
  final bool showAttribution;
  final int cadenceMinutes;

  /// 屏保 photo 模式下显示的背景图绝对路径; `null` 表示用默认渐变。
  final String? backgroundImagePath;

  /// 桌面小组件配色 (Issue #6 子任务 4, v0.15.7 起)。
  final WidgetColorTheme widgetColorTheme;

  /// 屏保当前选中版式的 key (v0.19.0 起, 对应 DisplayLayout.key)。
  final String displayLayoutKey;

  /// 桌面小组件 / 鸿蒙卡片"下一句"播放模式 (v0.19.1, Issue #11)。
  final WidgetPlayMode widgetPlayMode;

  /// 全局字号档位 (v0.27.0)。
  final AppFontScale fontScale;

  /// 小组件来源标签 (v0.29.0, 设计源「来自哪个标签」); `null` 表示整库。
  /// 不存「全部」哨兵是有意的: data 层不依赖 domain 层的哨兵常量。
  final String? widgetSourceTag;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? shuffleNoRepeat,
    bool? showAttribution,
    int? cadenceMinutes,
    String? backgroundImagePath,
    bool clearBackgroundImage = false,
    WidgetColorTheme? widgetColorTheme,
    String? displayLayoutKey,
    WidgetPlayMode? widgetPlayMode,
    AppFontScale? fontScale,
    String? widgetSourceTag,
    bool clearWidgetSourceTag = false,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      shuffleNoRepeat: shuffleNoRepeat ?? this.shuffleNoRepeat,
      showAttribution: showAttribution ?? this.showAttribution,
      cadenceMinutes: cadenceMinutes ?? this.cadenceMinutes,
      backgroundImagePath: clearBackgroundImage
          ? null
          : (backgroundImagePath ?? this.backgroundImagePath),
      widgetColorTheme: widgetColorTheme ?? this.widgetColorTheme,
      displayLayoutKey: displayLayoutKey ?? this.displayLayoutKey,
      widgetPlayMode: widgetPlayMode ?? this.widgetPlayMode,
      fontScale: fontScale ?? this.fontScale,
      widgetSourceTag: clearWidgetSourceTag
          ? null
          : (widgetSourceTag ?? this.widgetSourceTag),
    );
  }

  static const AppSettings defaults = AppSettings(
    themeMode: AppThemeMode.system,
    shuffleNoRepeat: true,
    showAttribution: true,
    cadenceMinutes: 30,
    backgroundImagePath: null,
    widgetColorTheme: WidgetColorTheme.paper,
    displayLayoutKey: defaultDisplayLayoutKey,
    widgetPlayMode: WidgetPlayMode.random,
    fontScale: AppFontScale.standard,
    widgetSourceTag: null,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettings &&
          other.themeMode == themeMode &&
          other.shuffleNoRepeat == shuffleNoRepeat &&
          other.showAttribution == showAttribution &&
          other.cadenceMinutes == cadenceMinutes &&
          other.backgroundImagePath == backgroundImagePath &&
          other.widgetColorTheme == widgetColorTheme &&
          other.displayLayoutKey == displayLayoutKey &&
          other.widgetPlayMode == widgetPlayMode &&
          other.fontScale == fontScale &&
          other.widgetSourceTag == widgetSourceTag);

  @override
  int get hashCode => Object.hash(
        themeMode,
        shuffleNoRepeat,
        showAttribution,
        cadenceMinutes,
        backgroundImagePath,
        widgetColorTheme,
        displayLayoutKey,
        widgetPlayMode,
        fontScale,
        widgetSourceTag,
      );
}
