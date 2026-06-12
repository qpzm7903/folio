/// 全局设置 model 与对应枚举。
///
/// 不耦合 [SharedPreferences]; IO 适配在 `settings_repository.dart` 里。
library;

import 'widget_color_theme.dart';

export 'widget_color_theme.dart' show WidgetColorTheme;

enum AppThemeMode { system, paper, night }

extension AppThemeModeLabel on AppThemeMode {
  /// 用户可见标签 —— 中文为主。
  String get displayLabel {
    switch (this) {
      case AppThemeMode.system:
        return '跟随系统';
      case AppThemeMode.paper:
        return '青纸 · Paper';
      case AppThemeMode.night:
        return '林夜 · Forest';
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
  });

  final AppThemeMode themeMode;
  final bool shuffleNoRepeat;
  final bool showAttribution;
  final int cadenceMinutes;

  /// 屏保 photo 模式下显示的背景图绝对路径; `null` 表示用默认渐变。
  final String? backgroundImagePath;

  /// 桌面小组件配色 (Issue #6 子任务 4, v0.15.7 起)。
  final WidgetColorTheme widgetColorTheme;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? shuffleNoRepeat,
    bool? showAttribution,
    int? cadenceMinutes,
    String? backgroundImagePath,
    bool clearBackgroundImage = false,
    WidgetColorTheme? widgetColorTheme,
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
    );
  }

  static const AppSettings defaults = AppSettings(
    themeMode: AppThemeMode.system,
    shuffleNoRepeat: true,
    showAttribution: true,
    cadenceMinutes: 30,
    backgroundImagePath: null,
    widgetColorTheme: WidgetColorTheme.paper,
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
          other.widgetColorTheme == widgetColorTheme);

  @override
  int get hashCode => Object.hash(
        themeMode,
        shuffleNoRepeat,
        showAttribution,
        cadenceMinutes,
        backgroundImagePath,
        widgetColorTheme,
      );
}
