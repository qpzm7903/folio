import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';
import 'ohos_prefs_bridge.dart';

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
  static const String _kDisplayLayout = 'folio.settings.displayLayoutKey';
  static const String _kPlayMode = 'folio.settings.widgetPlayMode';
  static const String _kFontScale = 'folio.settings.fontScale';

  AppSettings load() {
    final String? bg = _prefs.getString(_kBgImage);
    final String? layout = _prefs.getString(_kDisplayLayout);
    return AppSettings(
      themeMode: _decodeEnum(
          AppThemeMode.values, _prefs.getString(_kTheme), AppThemeMode.system),
      shuffleNoRepeat: _prefs.getBool(_kShuffle) ?? true,
      showAttribution: _prefs.getBool(_kShowSrc) ?? true,
      cadenceMinutes: _prefs.getInt(_kCadence) ?? 30,
      backgroundImagePath: (bg != null && bg.isNotEmpty) ? bg : null,
      widgetColorTheme: _decodeEnum(WidgetColorTheme.values,
          _prefs.getString(_kWidgetColor), WidgetColorTheme.paper),
      displayLayoutKey: (layout != null && layout.isNotEmpty)
          ? layout
          : AppSettings.defaultDisplayLayoutKey,
      widgetPlayMode: _decodeEnum(WidgetPlayMode.values,
          _prefs.getString(_kPlayMode), WidgetPlayMode.random),
      fontScale: _decodeEnum(AppFontScale.values,
          _prefs.getString(_kFontScale), AppFontScale.standard),
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
    await _prefs.setString(_kDisplayLayout, s.displayLayoutKey);
    await _prefs.setString(_kPlayMode, s.widgetPlayMode.name);
    await _prefs.setString(_kFontScale, s.fontScale.name);
    // 鸿蒙: 落盘到 ArkTS preferences (非鸿蒙平台 no-op)。
    await OhosPrefsBridge.instance.flush(_prefs);
  }


  /// 通用枚举解码 —— 按持久化的 `name` 匹配, 未知/缺失回落 [fallback]
  /// (v0.27.1 收敛四份同构 firstWhere 样板)。
  static T _decodeEnum<T extends Enum>(
    List<T> values,
    String? name,
    T fallback,
  ) {
    for (final T v in values) {
      if (v.name == name) return v;
    }
    return fallback;
  }
}
