import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/app_settings.dart';
import 'package:folio/data/settings_repository.dart';
import 'package:folio/presentation/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<ProviderContainer> makeContainer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: <Override>[sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  }

  group('SettingsNotifier setters via _apply', () {
    test('每个 setter 都更新 state 并落盘到 prefs', () async {
      final ProviderContainer c = await makeContainer();
      expect(c.read(settingsProvider), AppSettings.defaults);

      await c.read(settingsProvider.notifier).setThemeMode(AppThemeMode.night);
      await c.read(settingsProvider.notifier).setCadenceMinutes(60);
      await c.read(settingsProvider.notifier).setShuffleNoRepeat(false);
      await c.read(settingsProvider.notifier).setShowAttribution(false);
      await c
          .read(settingsProvider.notifier)
          .setBackgroundImagePath('/tmp/bg.jpg');
      await c
          .read(settingsProvider.notifier)
          .setWidgetColorTheme(WidgetColorTheme.bamboo);
      await c
          .read(settingsProvider.notifier)
          .setWidgetPlayMode(WidgetPlayMode.sequential);

      // 验证 state
      final AppSettings s = c.read(settingsProvider);
      expect(s.themeMode, AppThemeMode.night);
      expect(s.cadenceMinutes, 60);
      expect(s.shuffleNoRepeat, isFalse);
      expect(s.showAttribution, isFalse);
      expect(s.backgroundImagePath, '/tmp/bg.jpg');
      expect(s.widgetColorTheme, WidgetColorTheme.bamboo);
      expect(s.widgetPlayMode, WidgetPlayMode.sequential);

      // 验证落盘: 重新建一个 container, 应该 load 出同样的值
      c.dispose();
      final ProviderContainer c2 = await makeContainer();
      final AppSettings persisted = c2.read(settingsProvider);
      expect(persisted, s);
      c2.dispose();
    });

    test('setBackgroundImagePath(null) 真清空 prefs', () async {
      final ProviderContainer c = await makeContainer();
      await c
          .read(settingsProvider.notifier)
          .setBackgroundImagePath('/tmp/bg.jpg');
      await c.read(settingsProvider.notifier).setBackgroundImagePath(null);
      expect(c.read(settingsProvider).backgroundImagePath, isNull);

      c.dispose();
      final ProviderContainer c2 = await makeContainer();
      expect(c2.read(settingsProvider).backgroundImagePath, isNull);
      c2.dispose();
    });
  });
}
