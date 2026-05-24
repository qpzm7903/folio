import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/favorites_repository.dart';
import 'package:folio/presentation/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// FavoritesNotifier 行为 (v0.14.0 收藏列表屏依赖)。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  Future<ProviderContainer> _container() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: <Override>[sharedPreferencesProvider.overrideWithValue(p)],
    );
  }

  test('初始为空', () async {
    final ProviderContainer c = await _container();
    expect(c.read(favoritesProvider), isEmpty);
  });

  test('toggle 同一 id 两次 → 加入再移出', () async {
    final ProviderContainer c = await _container();
    final FavoritesNotifier n = c.read(favoritesProvider.notifier);
    await n.toggle('q1');
    expect(c.read(favoritesProvider), <String>{'q1'});
    await n.toggle('q1');
    expect(c.read(favoritesProvider), isEmpty);
  });

  test('落盘到 prefs, 重建 container 后还在', () async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    final ProviderContainer c1 = ProviderContainer(
      overrides: <Override>[sharedPreferencesProvider.overrideWithValue(p)],
    );
    await c1.read(favoritesProvider.notifier).toggle('q1');
    await c1.read(favoritesProvider.notifier).toggle('q2');
    c1.dispose();

    final ProviderContainer c2 = ProviderContainer(
      overrides: <Override>[sharedPreferencesProvider.overrideWithValue(p)],
    );
    expect(c2.read(favoritesProvider), <String>{'q1', 'q2'});
    // 直接 load from repo, 不依赖 notifier 状态
    expect(FavoritesRepository(p).load(), <String>{'q1', 'q2'});
  });
}
