import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';

// 重新导出 model, 让现有 `import 'settings_repository.dart'` 拿到 AppSettings /
// AppThemeMode / AppThemeModeLabel 的调用方不必同时改 import 路径。
export 'app_settings.dart';

/// 跟 [AppSettings] 一一对应的 SharedPreferences 持久化层。
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _kTheme = 'folio.settings.theme';
  static const String _kShuffle = 'folio.settings.shuffleNoRepeat';
  static const String _kShowSrc = 'folio.settings.showAttribution';
  static const String _kCadence = 'folio.settings.cadenceMinutes';
  static const String _kBgImage = 'folio.settings.backgroundImagePath';
  static const String _kWidgetColor = 'folio.settings.widgetColorTheme';

  AppSettings load() {
    final String? bg = _prefs.getString(_kBgImage);
    return AppSettings(
      themeMode: _decodeTheme(_prefs.getString(_kTheme)),
      shuffleNoRepeat: _prefs.getBool(_kShuffle) ?? true,
      showAttribution: _prefs.getBool(_kShowSrc) ?? true,
      cadenceMinutes: _prefs.getInt(_kCadence) ?? 30,
      backgroundImagePath: (bg != null && bg.isNotEmpty) ? bg : null,
      widgetColorTheme: _decodeWidgetColor(_prefs.getString(_kWidgetColor)),
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
    await _prefs.setString(_kWidgetColor, s.widgetColorTheme.name);
  }

  AppThemeMode _decodeTheme(String? name) {
    return AppThemeMode.values.firstWhere(
      (AppThemeMode m) => m.name == name,
      orElse: () => AppThemeMode.system,
    );
  }

  WidgetColorTheme _decodeWidgetColor(String? name) {
    return WidgetColorTheme.values.firstWhere(
      (WidgetColorTheme t) => t.name == name,
      orElse: () => WidgetColorTheme.paper,
    );
  }
}
