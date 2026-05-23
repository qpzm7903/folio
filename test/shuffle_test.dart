import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:folio/domain/shuffle.dart';

void main() {
  group('shuffleArr', () {
    test('保持原数组不变, 返回新副本', () {
      final List<int> input = <int>[1, 2, 3, 4, 5];
      final List<int> copy = List<int>.of(input);
      shuffleArr<int>(input);
      expect(input, copy);
    });

    test('结果和原数组元素相同', () {
      final List<int> input = List<int>.generate(20, (int i) => i);
      final List<int> shuffled = shuffleArr<int>(input);
      expect(shuffled.length, input.length);
      expect(<int>{...shuffled}, <int>{...input});
    });
  });

  group('NoRepeatShuffle', () {
    test('一轮内每个 index 都恰好出现一次', () {
      final NoRepeatShuffle s =
          NoRepeatShuffle(itemCount: 10, random: Random(42));
      final Set<int> seen = <int>{};
      seen.add(s.currentIndex);
      for (int i = 0; i < s.totalInRound - 1; i++) {
        s.next();
        seen.add(s.currentIndex);
      }
      expect(seen.length, 10);
      expect(s.round, 1);
    });

    test('整轮结束后会重洗, round +1', () {
      final NoRepeatShuffle s =
          NoRepeatShuffle(itemCount: 5, random: Random(7));
      // 走完第一轮 (4 次 next 从 pos=0 到 pos=4)
      for (int i = 0; i < 5; i++) {
        s.next();
      }
      expect(s.round, 2);
      expect(s.posInRound, 1);
    });

    test('新一轮的第一个 index 不会等于上一轮的最后一个', () {
      // 用一个能稳定复现的种子
      final NoRepeatShuffle s =
          NoRepeatShuffle(itemCount: 5, random: Random(1));
      // 走到第一轮最后
      for (int i = 0; i < 4; i++) {
        s.next();
      }
      final int last = s.currentIndex;
      s.next(); // 切到第 2 轮
      expect(s.currentIndex == last, isFalse,
          reason: 'last=$last, new first=${s.currentIndex}');
    });

    test('itemCount=1 时永远是 0, 不会崩溃', () {
      final NoRepeatShuffle s = NoRepeatShuffle(itemCount: 1);
      expect(s.currentIndex, 0);
      for (int i = 0; i < 5; i++) {
        s.next();
        expect(s.currentIndex, 0);
      }
    });

    test('itemCount=0 时降级到 currentIndex=0, next() 是 no-op', () {
      final NoRepeatShuffle s = NoRepeatShuffle(itemCount: 0);
      expect(s.currentIndex, 0);
      expect(() => s.next(), returnsNormally);
    });

    test('resetForNewLength 切换长度时重置状态', () {
      final NoRepeatShuffle s = NoRepeatShuffle(itemCount: 5);
      s.next();
      s.next();
      s.resetForNewLength(8);
      expect(s.totalInRound, 8);
      expect(s.posInRound, 1);
      expect(s.round, 1);
    });
  });
}
