import 'package:flutter_test/flutter_test.dart';
import 'package:folio/presentation/settings/settings_screen.dart';

void main() {
  group('cadenceLabel', () {
    test('返回带分钟数的中文', () {
      expect(cadenceLabel(5), '每 5 分钟换一句');
      expect(cadenceLabel(30), '每 30 分钟换一句');
      expect(cadenceLabel(240), '每 240 分钟换一句');
    });

    test('kCadenceChoices 全部映射出非空标签', () {
      for (final int m in kCadenceChoices) {
        expect(cadenceLabel(m), isNotEmpty);
      }
    });
  });
}
