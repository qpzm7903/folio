/// 全局设置 model 与对应枚举。
///
/// 不耦合 [SharedPreferences]; IO 适配在 `settings_repository.dart` 里。
library;

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
  });

  final AppThemeMode themeMode;
  final bool shuffleNoRepeat;
  final bool showAttribution;
  final int cadenceMinutes;

  /// 屏保 photo 模式下显示的背景图绝对路径; `null` 表示用默认渐变。
  final String? backgroundImagePath;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? shuffleNoRepeat,
    bool? showAttribution,
    int? cadenceMinutes,
    String? backgroundImagePath,
    bool clearBackgroundImage = false,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      shuffleNoRepeat: shuffleNoRepeat ?? this.shuffleNoRepeat,
      showAttribution: showAttribution ?? this.showAttribution,
      cadenceMinutes: cadenceMinutes ?? this.cadenceMinutes,
      backgroundImagePath: clearBackgroundImage
          ? null
          : (backgroundImagePath ?? this.backgroundImagePath),
    );
  }

  static const AppSettings defaults = AppSettings(
    themeMode: AppThemeMode.system,
    shuffleNoRepeat: true,
    showAttribution: true,
    cadenceMinutes: 30,
    backgroundImagePath: null,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettings &&
          other.themeMode == themeMode &&
          other.shuffleNoRepeat == shuffleNoRepeat &&
          other.showAttribution == showAttribution &&
          other.cadenceMinutes == cadenceMinutes &&
          other.backgroundImagePath == backgroundImagePath);

  @override
  int get hashCode => Object.hash(
    themeMode,
    shuffleNoRepeat,
    showAttribution,
    cadenceMinutes,
    backgroundImagePath,
  );
}
