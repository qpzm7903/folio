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
}
