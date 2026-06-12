import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/wallpaper_service.dart';
import 'package:folio/presentation/providers.dart';

void main() {
  group('WallpaperService', () {
    test('isSupported 在非 Android host (CI / 本地 macOS) 上为 false', () {
      // Platform.isAndroid 在 unit test 跑在 host machine 上一定是 false,
      // 锁住"测试环境不会意外调到真 MethodChannel"这条不变量。
      const WallpaperService service = WallpaperService();
      expect(service.isSupported, isFalse);
    });
  });

  group('wallpaperServiceProvider', () {
    test('cache 两次 read 拿到同一实例', () {
      final ProviderContainer c = ProviderContainer();
      final WallpaperService a = c.read(wallpaperServiceProvider);
      final WallpaperService b = c.read(wallpaperServiceProvider);
      expect(identical(a, b), isTrue);
      c.dispose();
    });

    test('overrideWithValue 注入 fake (测试可替换 MethodChannel 调用)', () {
      const _StubWallpaperService stub = _StubWallpaperService();
      final ProviderContainer c = ProviderContainer(
        overrides: <Override>[wallpaperServiceProvider.overrideWithValue(stub)],
      );
      expect(identical(c.read(wallpaperServiceProvider), stub), isTrue);
      c.dispose();
    });
  });
}

/// 测试 fake —— 继承 WallpaperService 让 provider override 接受。
/// 真实 service 的 setWallpaperFromBoundary 走 MethodChannel + path_provider,
/// 测试里不能跑; stub 重写 isSupported 让 UI 能跑 widget test 不 throw。
class _StubWallpaperService extends WallpaperService {
  const _StubWallpaperService();

  @override
  bool get isSupported => true;
}
