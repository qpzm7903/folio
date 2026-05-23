import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/domain/rotation_controller.dart';

void main() {
  group('RotationController', () {
    test('cadence 到了之后会自动 advance 并调 onAdvance', () {
      fakeAsync((FakeAsync async) {
        int ticks = 0;
        final RotationController c = RotationController(
          itemCount: 5,
          cadence: const Duration(minutes: 30),
          onAdvance: () => ticks++,
          random: Random(1),
        );
        final int start = c.currentIndex;

        async.elapse(const Duration(minutes: 30));
        expect(ticks, 1);
        expect(c.currentIndex, isNot(equals(start)));

        async.elapse(const Duration(minutes: 30));
        expect(ticks, 2);

        c.dispose();
      });
    });

    test('用户手动 advance 会重置 cadence', () {
      fakeAsync((FakeAsync async) {
        int ticks = 0;
        final RotationController c = RotationController(
          itemCount: 5,
          cadence: const Duration(minutes: 30),
          onAdvance: () => ticks++,
          random: Random(2),
        );

        // 25 分钟后用户手动切, 重置 cadence
        async.elapse(const Duration(minutes: 25));
        c.advance();
        expect(ticks, 1);

        // 再等 25 分钟, 不应自动触发 (因为 cadence 已经重置, 还要 5 分钟)
        async.elapse(const Duration(minutes: 25));
        expect(ticks, 1);

        // 再等 5 分钟, 自动触发
        async.elapse(const Duration(minutes: 5));
        expect(ticks, 2);

        c.dispose();
      });
    });

    test('reconfigure 变了 cadence 才重起 timer', () {
      fakeAsync((FakeAsync async) {
        int ticks = 0;
        final RotationController c = RotationController(
          itemCount: 5,
          cadence: const Duration(minutes: 30),
          onAdvance: () => ticks++,
        );

        async.elapse(const Duration(minutes: 20));
        // 切到 5 分钟频率
        c.reconfigure(newCadence: const Duration(minutes: 5));
        async.elapse(const Duration(minutes: 5));
        expect(ticks, 1);

        // 同样 cadence 再 reconfigure, 不重起 (再等 5 分钟仍会触发, 但不重复)
        c.reconfigure(newCadence: const Duration(minutes: 5));
        async.elapse(const Duration(minutes: 5));
        expect(ticks, 2);

        c.dispose();
      });
    });

    test('dispose 后 timer 不再触发', () {
      fakeAsync((FakeAsync async) {
        int ticks = 0;
        final RotationController c = RotationController(
          itemCount: 3,
          cadence: const Duration(minutes: 10),
          onAdvance: () => ticks++,
        );
        c.dispose();
        async.elapse(const Duration(hours: 5));
        expect(ticks, 0);
      });
    });
  });
}
