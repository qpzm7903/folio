import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/settings_repository.dart';

void main() {
  group('AppThemeModeLabel', () {
    test('每个枚举值都有非空中文标签', () {
      for (final AppThemeMode mode in AppThemeMode.values) {
        expect(
          mode.displayLabel,
          isNotEmpty,
          reason: '$mode should have a label',
        );
      }
    });

    test('具体映射稳定 (settings 屏依赖, 对齐 skill 名)', () {
      expect(AppThemeMode.system.displayLabel, '跟随系统');
      expect(AppThemeMode.paper.displayLabel, '青纸 · Tea Paper');
      expect(AppThemeMode.celadon.displayLabel, '天青 · Celadon');
      expect(AppThemeMode.moonwhite.displayLabel, '月白 · Moon White');
      expect(AppThemeMode.cinnabar.displayLabel, '绛霞 · Cinnabar');
      expect(AppThemeMode.night.displayLabel, '林夜 · Forest Night');
      expect(AppThemeMode.dai.displayLabel, '青黛 · Ink Indigo');
    });

    test('六主题 + 跟随系统 = 7 个设置项', () {
      expect(AppThemeMode.values.length, 7);
    });
  });
}
