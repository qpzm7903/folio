import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/ohos_prefs_bridge.dart';

void main() {
  group('OhosPrefsBridge 快照往返保真 (数据安全不变量)', () {
    test('String / bool / int / double / List<String> 全类型往返不丢不变型', () {
      // 鸿蒙落盘走 JSON, 必须保住类型: 否则 favorites(List<String>) 会变
      // List<dynamic>、cadence(int) 可能变 double, 重启后取值崩或丢。
      final Map<String, Object> original = <String, Object>{
        'folio.quotes.v1': '[{"text":"光从裂缝进来","tag":"种子"}]',
        'folio.settings.theme': 'night',
        'folio.settings.shuffleNoRepeat': false,
        'folio.settings.cadenceMinutes': 45,
        'folio.settings.ratio': 1.5,
        'folio.favorites.ids.v1': <String>['q-1', 'q-2', 'q-3'],
      };

      final String json = OhosPrefsBridge.encodeSnapshot(original);
      final Map<String, Object> restored = OhosPrefsBridge.decodeSnapshot(json);

      expect(restored['folio.quotes.v1'], isA<String>());
      expect(restored['folio.quotes.v1'], original['folio.quotes.v1']);

      expect(restored['folio.settings.theme'], 'night');

      expect(restored['folio.settings.shuffleNoRepeat'], isA<bool>());
      expect(restored['folio.settings.shuffleNoRepeat'], false);

      expect(restored['folio.settings.cadenceMinutes'], isA<int>());
      expect(restored['folio.settings.cadenceMinutes'], 45);

      expect(restored['folio.settings.ratio'], isA<double>());
      expect(restored['folio.settings.ratio'], 1.5);

      expect(restored['folio.favorites.ids.v1'], isA<List<String>>());
      expect(restored['folio.favorites.ids.v1'], <String>['q-1', 'q-2', 'q-3']);
    });

    test('空串 / 非法 JSON → 空 map, 不抛 (启动读不到时安全降级)', () {
      expect(OhosPrefsBridge.decodeSnapshot(''), <String, Object>{});
      expect(OhosPrefsBridge.decodeSnapshot('not json'), <String, Object>{});
      expect(OhosPrefsBridge.decodeSnapshot('[1,2,3]'), <String, Object>{});
    });

    test('空 prefs 编码为合法 JSON 空对象', () {
      final String json = OhosPrefsBridge.encodeSnapshot(<String, Object>{});
      expect(OhosPrefsBridge.decodeSnapshot(json), <String, Object>{});
    });
  });
}
