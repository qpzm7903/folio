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

    test('具体映射稳定 (settings 屏依赖)', () {
      expect(AppThemeMode.system.displayLabel, '跟随系统');
      expect(AppThemeMode.paper.displayLabel, '青纸 · Paper');
      expect(AppThemeMode.night.displayLabel, '林夜 · Forest');
    });
  });
}
