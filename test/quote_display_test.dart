import 'package:flutter_test/flutter_test.dart';
import 'package:folio/domain/quote_display.dart';

void main() {
  group('displayQuoteText 剥离序号前缀', () {
    test('剥掉 "200. " 半角点 + 空格', () {
      expect(displayQuoteText('200. 如果尝试了上百次都没有成功'), '如果尝试了上百次都没有成功');
    });

    test('剥掉 "9." 无空格', () {
      expect(displayQuoteText('9.无论工作再忙'), '无论工作再忙');
    });

    test('剥掉全角顿号 "12、"', () {
      expect(displayQuoteText('12、心态要平和'), '心态要平和');
    });

    test('剥掉全角句点 "3．"', () {
      expect(displayQuoteText('3．一个优秀的小说'), '一个优秀的小说');
    });

    test('不误伤以数字开头但无分隔符的正文', () {
      expect(displayQuoteText('1984 年那个夏天'), '1984 年那个夏天');
    });

    test('无前缀原样返回', () {
      expect(displayQuoteText('山有木兮木有枝'), '山有木兮木有枝');
    });

    test('整句只是编号时保留原文 (不返回空)', () {
      expect(displayQuoteText('200.'), '200.');
    });

    test('只剥一次, 不连环剥', () {
      expect(displayQuoteText('1. 2. 双重'), '2. 双重');
    });
  });
}
