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
          .setWidgetColorTheme(WidgetColorTheme.celadon);
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
      expect(s.widgetColorTheme, WidgetColorTheme.celadon);
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

    test('widgetSourceTag round-trip + 置 null 真清空 (v0.29.0 来源标签)',
        () async {
      final ProviderContainer c = await makeContainer();
      expect(c.read(settingsProvider).widgetSourceTag, isNull);

      await c.read(settingsProvider.notifier).setWidgetSourceTag('坚持');
      expect(c.read(settingsProvider).widgetSourceTag, '坚持');

      // 落盘验证
      c.dispose();
      final ProviderContainer c2 = await makeContainer();
      expect(c2.read(settingsProvider).widgetSourceTag, '坚持');

      // 选回「全部」→ 存 null 并真清空
      await c2.read(settingsProvider.notifier).setWidgetSourceTag(null);
      expect(c2.read(settingsProvider).widgetSourceTag, isNull);
      c2.dispose();
      final ProviderContainer c3 = await makeContainer();
      expect(c3.read(settingsProvider).widgetSourceTag, isNull);
      c3.dispose();
    });

    test('WidgetColorTheme 六主题 round-trip + 旧值 bamboo fallback paper',
        () async {
      // 六主题都能 round-trip
      for (final WidgetColorTheme c in WidgetColorTheme.values) {
        final ProviderContainer container = await makeContainer();
        await container.read(settingsProvider.notifier).setWidgetColorTheme(c);
        expect(container.read(settingsProvider).widgetColorTheme, c);
        container.dispose();

        // 重新加载验证落盘
        final ProviderContainer c2 = await makeContainer();
        expect(c2.read(settingsProvider).widgetColorTheme, c);
        c2.dispose();
      }

      // 旧版持久化的 'bamboo' 值 (v0.21.0 已移除) 应 fallback 到 paper
      SharedPreferences.setMockInitialValues(
        <String, Object>{'folio.settings.widgetColorTheme': 'bamboo'},
      );
      final ProviderContainer c3 = await makeContainer();
      expect(
        c3.read(settingsProvider).widgetColorTheme,
        WidgetColorTheme.paper,
      );
      c3.dispose();
    });
  });
}
