import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/bootstrap.dart';
import 'package:folio/data/quote_repository.dart';
import 'package:folio/presentation/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `path_provider` 走 plugin channel, flutter_test 默认无 plugin 注册;
/// 直接调 `getApplicationSupportDirectory` 会抛 MissingPluginException。
/// 这里 mock 该 channel 返回一个真实的临时目录, 让 AppLogger.init /
/// QuoteRepository 都能正常工作。
void _mockPathProvider() {
  final Directory tmp = Directory.systemTemp.createTempSync('folio-bootstrap-');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (MethodCall call) async {
      // 所有目录请求 (support / documents / temp / cache / library) 都返回同一个 tmp
      return tmp.path;
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bootstrap.initialize', () {
    setUp(() {
      _mockPathProvider();
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test(
      '返回 overrides 至少包含 sharedPreferencesProvider + quoteRepositoryProvider',
      () async {
        final List<Override> overrides = await Bootstrap.initialize();
        expect(overrides.length, greaterThanOrEqualTo(2));

        final ProviderContainer c = ProviderContainer(overrides: overrides);
        expect(c.read(sharedPreferencesProvider), isA<SharedPreferences>());
        expect(c.read(quoteRepositoryProvider), isA<QuoteRepository>());
        c.dispose();
      },
    );

    test('多次 initialize 不互相破坏 (ensureInitialized 幂等)', () async {
      await Bootstrap.initialize();
      final List<Override> second = await Bootstrap.initialize();
      expect(second.length, greaterThanOrEqualTo(2));
    });
  });
}
