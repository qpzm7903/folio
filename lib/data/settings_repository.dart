import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, paper, night }

extension AppThemeModeLabel on AppThemeMode {
  /// 用户可见标签 —— 中文为主, 跟 settings 屏一致。
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
}

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _kTheme = 'folio.settings.theme';
  static const String _kShuffle = 'folio.settings.shuffleNoRepeat';
  static const String _kShowSrc = 'folio.settings.showAttribution';
  static const String _kCadence = 'folio.settings.cadenceMinutes';
  static const String _kBgImage = 'folio.settings.backgroundImagePath';

  AppSettings load() {
    final String? bg = _prefs.getString(_kBgImage);
    return AppSettings(
      themeMode: _decodeTheme(_prefs.getString(_kTheme)),
      shuffleNoRepeat: _prefs.getBool(_kShuffle) ?? true,
      showAttribution: _prefs.getBool(_kShowSrc) ?? true,
      cadenceMinutes: _prefs.getInt(_kCadence) ?? 30,
      backgroundImagePath: (bg != null && bg.isNotEmpty) ? bg : null,
    );
  }

  Future<void> save(AppSettings s) async {
    await _prefs.setString(_kTheme, s.themeMode.name);
    await _prefs.setBool(_kShuffle, s.shuffleNoRepeat);
    await _prefs.setBool(_kShowSrc, s.showAttribution);
    await _prefs.setInt(_kCadence, s.cadenceMinutes);
    if (s.backgroundImagePath == null) {
      await _prefs.remove(_kBgImage);
    } else {
      await _prefs.setString(_kBgImage, s.backgroundImagePath!);
    }
  }

  AppThemeMode _decodeTheme(String? name) {
    return AppThemeMode.values.firstWhere(
      (AppThemeMode m) => m.name == name,
      orElse: () => AppThemeMode.system,
    );
  }
}
