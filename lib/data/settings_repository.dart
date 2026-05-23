import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, paper, night }

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.shuffleNoRepeat,
    required this.showAttribution,
    required this.cadenceMinutes,
  });

  final AppThemeMode themeMode;
  final bool shuffleNoRepeat;
  final bool showAttribution;
  final int cadenceMinutes;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? shuffleNoRepeat,
    bool? showAttribution,
    int? cadenceMinutes,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      shuffleNoRepeat: shuffleNoRepeat ?? this.shuffleNoRepeat,
      showAttribution: showAttribution ?? this.showAttribution,
      cadenceMinutes: cadenceMinutes ?? this.cadenceMinutes,
    );
  }

  static const AppSettings defaults = AppSettings(
    themeMode: AppThemeMode.system,
    shuffleNoRepeat: true,
    showAttribution: true,
    cadenceMinutes: 30,
  );
}

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _kTheme = 'folio.settings.theme';
  static const String _kShuffle = 'folio.settings.shuffleNoRepeat';
  static const String _kShowSrc = 'folio.settings.showAttribution';
  static const String _kCadence = 'folio.settings.cadenceMinutes';

  AppSettings load() {
    return AppSettings(
      themeMode: _decodeTheme(_prefs.getString(_kTheme)),
      shuffleNoRepeat: _prefs.getBool(_kShuffle) ?? true,
      showAttribution: _prefs.getBool(_kShowSrc) ?? true,
      cadenceMinutes: _prefs.getInt(_kCadence) ?? 30,
    );
  }

  Future<void> save(AppSettings s) async {
    await _prefs.setString(_kTheme, s.themeMode.name);
    await _prefs.setBool(_kShuffle, s.shuffleNoRepeat);
    await _prefs.setBool(_kShowSrc, s.showAttribution);
    await _prefs.setInt(_kCadence, s.cadenceMinutes);
  }

  AppThemeMode _decodeTheme(String? name) {
    return AppThemeMode.values.firstWhere(
      (AppThemeMode m) => m.name == name,
      orElse: () => AppThemeMode.system,
    );
  }
}
