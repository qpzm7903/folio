import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// v0.27.0 字号设置 —— 设计源 SettingsScreen「字号」行落地。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppFontScale', () {
    test('三档标签与缩放因子', () {
      expect(AppFontScale.standard.displayLabel, '标准');
      expect(AppFontScale.large.displayLabel, '大');
      expect(AppFontScale.xlarge.displayLabel, '特大');
      expect(AppFontScale.standard.factor, 1.0);
      expect(AppFontScale.large.factor, 1.15);
      expect(AppFontScale.xlarge.factor, 1.3);
    });

    test('默认标准档', () {
      expect(AppSettings.defaults.fontScale, AppFontScale.standard);
    });
  });

  group('SettingsRepository fontScale 持久化', () {
    Future<SettingsRepository> repo([Map<String, Object>? seed]) async {
      SharedPreferences.setMockInitialValues(seed ?? <String, Object>{});
      return SettingsRepository(await SharedPreferences.getInstance());
    }

    test('save → load 往返', () async {
      final SettingsRepository r = await repo();
      await r.save(
        AppSettings.defaults.copyWith(fontScale: AppFontScale.xlarge),
      );
      expect(r.load().fontScale, AppFontScale.xlarge);
    });

    test('未知存量值回落标准档', () async {
      final SettingsRepository r = await repo(<String, Object>{
        'folio.settings.fontScale': 'huge-nonsense',
      });
      expect(r.load().fontScale, AppFontScale.standard);
    });

    test('无存档默认标准档', () async {
      final SettingsRepository r = await repo();
      expect(r.load().fontScale, AppFontScale.standard);
    });
  });
}
