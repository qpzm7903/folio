import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';

void main() {
  group('Quote JSON 互转', () {
    test('toJson/fromJson 双向无损', () {
      final Quote q = Quote(
        id: 'abc',
        text: '你在心里种下的种子，时间会帮它找出口。',
        tag: '坚持与回响',
        createdAt: DateTime.utc(2026, 5, 23, 10, 30),
      );
      final Quote back = Quote.fromJson(q.toJson());
      expect(back, q);
    });

    test('fromJson 容错缺失 tag/createdAt', () {
      final Quote q = Quote.fromJson(<String, dynamic>{
        'id': '1',
        'text': '光从裂痕里照进来。',
      });
      expect(q.tag, isEmpty);
      // createdAt 兜底成 now 附近, 不至于崩
      expect(q.createdAt.isBefore(DateTime.now().add(const Duration(seconds: 1))),
          isTrue);
    });
  });
}
