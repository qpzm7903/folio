import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/domain/widget_timeline.dart';

Quote _q(String id) => Quote(
      id: id,
      text: 'text-$id',
      tag: 'tag-$id',
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  group('WidgetTimeline.generate', () {
    test('空 quotes 返回空 timeline (native 应该回落 empty hint)', () {
      expect(WidgetTimeline.generate(const <Quote>[]), isEmpty);
    });

    test('length <= 0 返回空 (防御性)', () {
      expect(
        WidgetTimeline.generate(<Quote>[_q('a')], length: 0),
        isEmpty,
      );
    });

    test('quotes 比 length 短: 跨多轮拼到 length, 每条都是源 quotes 之一', () {
      final List<Quote> source = <Quote>[_q('a'), _q('b'), _q('c')];
      final List<Quote> timeline = WidgetTimeline.generate(
        source,
        length: 10,
        seed: 42,
      );
      expect(timeline, hasLength(10));
      final Set<String> sourceIds = source.map((Quote q) => q.id).toSet();
      for (final Quote q in timeline) {
        expect(sourceIds.contains(q.id), isTrue);
      }
    });

    test('quotes 比 length 长: 一轮内不重复 (NoRepeatShuffle 语义)', () {
      final List<Quote> source = List<Quote>.generate(
        30,
        (int i) => _q('q$i'),
      );
      final List<Quote> timeline = WidgetTimeline.generate(
        source,
        length: 20,
        seed: 42,
      );
      expect(timeline, hasLength(20));
      // 20 < 30, 不跨轮, 应该全 unique
      final Set<String> ids = timeline.map((Quote q) => q.id).toSet();
      expect(ids.length, 20);
    });

    test('seed 相同 → 序列稳定 (测试确定性)', () {
      final List<Quote> source = List<Quote>.generate(
        10,
        (int i) => _q('q$i'),
      );
      final List<Quote> a = WidgetTimeline.generate(
        source,
        length: 5,
        seed: 7,
      );
      final List<Quote> b = WidgetTimeline.generate(
        source,
        length: 5,
        seed: 7,
      );
      expect(
          a.map((Quote q) => q.id).toList(), b.map((Quote q) => q.id).toList());
    });

    test('Issue #11: 省略 length 默认覆盖整个金库 (不再固定取 20)', () {
      final List<Quote> source = List<Quote>.generate(
        50,
        (int i) => _q('q$i'),
      );
      final List<Quote> timeline = WidgetTimeline.generate(source, seed: 1);
      expect(timeline, hasLength(50), reason: '整库 50 条都在, 不止 20');
      expect(timeline.map((Quote q) => q.id).toSet().length, 50);
    });

    test('Issue #11: 顺序模式 (shuffle=false) 按库原序', () {
      final List<Quote> source = <Quote>[_q('a'), _q('b'), _q('c')];
      final List<Quote> timeline =
          WidgetTimeline.generate(source, shuffle: false);
      expect(
        timeline.map((Quote q) => q.id).toList(),
        <String>['a', 'b', 'c'],
      );
    });

    test('超大金库截断到 maxLength (防 prefs/RemoteViews 过大)', () {
      final List<Quote> source = List<Quote>.generate(
        WidgetTimeline.maxLength + 200,
        (int i) => _q('q$i'),
      );
      expect(
        WidgetTimeline.generate(source, seed: 1),
        hasLength(WidgetTimeline.maxLength),
      );
    });
  });

  group('WidgetTimeline.serialize/deserialize', () {
    test('round-trip 保留 text + tag', () {
      final List<Quote> source = <Quote>[
        _q('a'),
        Quote(
          id: 'b',
          text: '你在心里种下的种子, 时间会帮它找出口。',
          tag: '坚持与回响',
          createdAt: DateTime(2026, 1, 1),
        ),
      ];
      final String json = WidgetTimeline.serialize(source);
      final List<({String text, String tag})> decoded =
          WidgetTimeline.deserialize(json);
      expect(decoded, hasLength(2));
      expect(decoded[0].text, 'text-a');
      expect(decoded[0].tag, 'tag-a');
      expect(decoded[1].text, '你在心里种下的种子, 时间会帮它找出口。');
      expect(decoded[1].tag, '坚持与回响');
    });

    test('deserialize 容错: 空串 / 非 list / 字段缺失', () {
      expect(WidgetTimeline.deserialize(''), isEmpty);
      expect(WidgetTimeline.deserialize('{"q":"x"}'), isEmpty);
      final List<({String text, String tag})> partial =
          WidgetTimeline.deserialize('[{"q":"hello"}]');
      expect(partial, hasLength(1));
      expect(partial[0].text, 'hello');
      expect(partial[0].tag, '');
    });
  });
}
