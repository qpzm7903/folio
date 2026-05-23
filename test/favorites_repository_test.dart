import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/favorites_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FavoritesRepository (v0.13.3 修 #4)', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('load 空 prefs → 空 set', () async {
      final SharedPreferences p = await SharedPreferences.getInstance();
      final FavoritesRepository repo = FavoritesRepository(p);
      expect(repo.load(), isEmpty);
    });

    test('save 再 load 回原集合', () async {
      final SharedPreferences p = await SharedPreferences.getInstance();
      final FavoritesRepository repo = FavoritesRepository(p);
      await repo.save(<String>{'a', 'b', 'c'});
      expect(repo.load(), <String>{'a', 'b', 'c'});
    });

    test('save 空集合后 load 也是空', () async {
      final SharedPreferences p = await SharedPreferences.getInstance();
      final FavoritesRepository repo = FavoritesRepository(p);
      await repo.save(<String>{'x'});
      await repo.save(<String>{});
      expect(repo.load(), isEmpty);
    });
  });
}
