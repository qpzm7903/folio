import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/rotation_state_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// v0.26.0: 屏保轮播状态 (id 顺序 + 位置 + 轮次) 的 prefs 持久化。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<RotationStateRepository> repo([Map<String, Object>? seed]) async {
    SharedPreferences.setMockInitialValues(seed ?? <String, Object>{});
    return RotationStateRepository(await SharedPreferences.getInstance());
  }

  test('save → load 往返无损', () async {
    final RotationStateRepository r = await repo();
    await r.save((ids: <String>['a', 'b', 'c'], pos: 1, round: 2));

    final RotationSnapshot? got = r.load();
    expect(got, isNotNull);
    expect(got!.ids, <String>['a', 'b', 'c']);
    expect(got.pos, 1);
    expect(got.round, 2);
  });

  test('无存档 → null', () async {
    final RotationStateRepository r = await repo();
    expect(r.load(), isNull);
  });

  test('损坏 JSON → null 且不抛', () async {
    final RotationStateRepository r = await repo(<String, Object>{
      RotationStateRepository.prefsKey: '{oops',
    });
    expect(r.load(), isNull);
  });

  test('字段类型不对 → null 且不抛', () async {
    final RotationStateRepository r = await repo(<String, Object>{
      RotationStateRepository.prefsKey: '{"ids": "not-a-list", "pos": 0, "round": 1}',
    });
    expect(r.load(), isNull);
  });
}
