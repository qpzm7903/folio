import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/platform_capabilities.dart';

void main() {
  group('PlatformCapabilities (host = test = dart_io ~= unknown / macOS)', () {
    test('isWeb 在 flutter_test 上是 false', () {
      expect(PlatformCapabilities.isWeb, isFalse);
    });

    test('isAndroid / isIOS 在 host 上都是 false', () {
      // flutter_test 默认跑在 host (macOS / Linux / Windows), 不是 mobile
      expect(PlatformCapabilities.isMobile, isFalse);
    });

    test('isDesktop / isMobile 互斥, 都不是 web', () {
      expect(PlatformCapabilities.isDesktop, isTrue);
      expect(PlatformCapabilities.isMobile, isFalse);
      expect(PlatformCapabilities.isWeb, isFalse);
    });

    test('supportsFileSelector = !isWeb', () {
      expect(PlatformCapabilities.supportsFileSelector, isTrue);
    });

    test('supportsHomeWidget = isMobile (host 上是 false)', () {
      expect(PlatformCapabilities.supportsHomeWidget, isFalse);
    });

    test('isOhos 在 host 上是 false', () {
      expect(PlatformCapabilities.isOhos, isFalse);
    });

    test('supportsSetWallpaper 只在 Android 上 true (host 上是 false)', () {
      expect(PlatformCapabilities.supportsSetWallpaper, isFalse);
    });

    test('supportsWidgetAlarm 只在 Android 上 true (host 上是 false)', () {
      expect(PlatformCapabilities.supportsWidgetAlarm, isFalse);
    });
  });
}
