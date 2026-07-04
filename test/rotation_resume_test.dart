import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:folio/domain/rotation_resume.dart';
import 'package:folio/domain/shuffle.dart';

/// v0.26.0 屏保轮播续位 (HANDOFF 第二轮收尾): 洗牌顺序持久化为 quote-id
/// 序列, 重启后翻译回索引接着放; 金库内容变了 (id 集合不一致) 则放弃续位。
void main() {
  group('mapOrderToIndices', () {
    const List<String> current = <String>['a', 'b', 'c', 'd'];

    test('保存的 id 顺序是当前集合的排列 → 翻译成索引', () {
      expect(
        mapOrderToIndices(<String>['c', 'a', 'd', 'b'], current),
        <int>[2, 0, 3, 1],
      );
    });

    test('长度不一致 (加了/删了句子) → null', () {
      expect(mapOrderToIndices(<String>['a', 'b', 'c'], current), isNull);
    });

    test('包含未知 id (句子被换掉) → null', () {
      expect(
        mapOrderToIndices(<String>['a', 'b', 'c', 'x'], current),
        isNull,
      );
    });

    test('重复 id (损坏数据) → null', () {
      expect(
        mapOrderToIndices(<String>['a', 'b', 'b', 'c'], current),
        isNull,
      );
    });

    test('空对空 → 空索引序列', () {
      expect(mapOrderToIndices(<String>[], <String>[]), <int>[]);
    });
  });

  group('NoRepeatShuffle.restore', () {
    test('从快照恢复: currentIndex 接在上次位置', () {
      final NoRepeatShuffle s = NoRepeatShuffle.restore(
        itemCount: 4,
        order: <int>[2, 0, 3, 1],
        pos: 2,
        round: 3,
      );
      expect(s.currentIndex, 3);
      expect(s.round, 3);
      expect(s.posInRound, 3);
    });

    test('恢复后 next() 走完本轮再重洗进入下一轮', () {
      final NoRepeatShuffle s = NoRepeatShuffle.restore(
        itemCount: 3,
        order: <int>[1, 2, 0],
        pos: 1,
        round: 2,
        random: Random(7),
      );
      s.next(); // → pos 2 (index 0)
      expect(s.currentIndex, 0);
      expect(s.round, 2);
      s.next(); // 本轮走完 → 重洗, round 3
      expect(s.round, 3);
      expect(s.posInRound, 1);
    });

    test('order 快照 getter 与恢复输入一致且不可变', () {
      final NoRepeatShuffle s = NoRepeatShuffle.restore(
        itemCount: 3,
        order: <int>[2, 1, 0],
        pos: 0,
        round: 1,
      );
      expect(s.order, <int>[2, 1, 0]);
      expect(s.position, 0);
      expect(() => s.order.add(9), throwsUnsupportedError);
    });

    test('新建实例也能导出快照再恢复 (roundtrip)', () {
      final NoRepeatShuffle a = NoRepeatShuffle(itemCount: 5, random: Random(1));
      a.next();
      a.next();
      final NoRepeatShuffle b = NoRepeatShuffle.restore(
        itemCount: 5,
        order: a.order,
        pos: a.position,
        round: a.round,
      );
      expect(b.currentIndex, a.currentIndex);
      expect(b.round, a.round);
    });
  });
}
