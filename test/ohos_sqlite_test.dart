import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/ohos_sqlite.dart';

void main() {
  group('configureOhosSqlite', () {
    test('非鸿蒙平台不应用 override, 返回 false', () {
      bool applied = false;
      final bool result = configureOhosSqlite(
        isOhos: false,
        applyOverride: () => applied = true,
      );
      expect(result, isFalse);
      expect(applied, isFalse);
    });

    test('鸿蒙平台应用 override, 返回 true', () {
      bool applied = false;
      final bool result = configureOhosSqlite(
        isOhos: true,
        applyOverride: () => applied = true,
      );
      expect(result, isTrue);
      expect(applied, isTrue);
    });

    test('isOhos 缺省时读 PlatformCapabilities (host 上是 false)', () {
      bool applied = false;
      final bool result = configureOhosSqlite(
        applyOverride: () => applied = true,
      );
      expect(result, isFalse);
      expect(applied, isFalse);
    });
  });
}
