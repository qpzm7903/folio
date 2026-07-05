import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/data/quote_codec.dart';

void main() {
  group('QuoteCodec', () {
    test('encode / tryDecode 双向无损', () {
      final List<Quote> input = <Quote>[
        Quote(
          id: '1',
          text: '光从裂痕里照进来。',
          tag: '完整而非完美',
          createdAt: DateTime.utc(2026, 5, 23, 8),
        ),
        Quote(
          id: '2',
          text: '不必急着去对岸，此刻的波浪也是风景。',
          tag: '旅程与抵达',
          createdAt: DateTime.utc(2026, 5, 22),
        ),
      ];
      final String raw = QuoteCodec.encode(input);
      final List<Quote>? out = QuoteCodec.tryDecode(raw);
      expect(out, isNotNull);
      expect(out, equals(input));
    });

    test('坏 JSON 返回 null, 不抛', () {
      final List<Quote>? out = QuoteCodec.tryDecode(
        'not json at all',
        context: 'unit test',
      );
      expect(out, isNull);
    });

    test('空数组', () {
      final String raw = QuoteCodec.encode(const <Quote>[]);
      expect(raw, '[]');
      expect(QuoteCodec.tryDecode(raw), isEmpty);
    });
  });

  // v0.28.0 纯文本导出 (设计源「备份为 .txt」)。
  group('QuoteCodec.encodePlainText', () {
    Quote q(String id, String text) => Quote(
          id: id,
          text: text,
          tag: '',
          createdAt: DateTime.utc(2026, 7, 1),
        );

    test('每行一句, 保持顺序', () {
      expect(
        QuoteCodec.encodePlainText(<Quote>[q('1', '甲句。'), q('2', '乙句。')]),
        '甲句。\n乙句。',
      );
    });

    test('只含句子内容, 不带标签/日期', () {
      final String out = QuoteCodec.encodePlainText(<Quote>[
        Quote(
          id: '1',
          text: '光。',
          tag: '完整',
          createdAt: DateTime.utc(2026, 5, 23),
        ),
      ]);
      expect(out, '光。');
    });

    test('空金库 → 空串', () {
      expect(QuoteCodec.encodePlainText(const <Quote>[]), '');
    });
  });
}
