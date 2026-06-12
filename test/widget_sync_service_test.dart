import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/data/widget_sync_service.dart';

void main() {
  group('WidgetSyncService 不变量', () {
    test('kWidgetCadenceFloorMin = 15 (锁住 plan.md 设计取舍 #1)', () {
      // v0.16.0 设计明确: 小组件下限 15 分钟。
      // AlarmManager doze 模式下实际能保证的最小间隔约 10-15min,
      // 1min 切一次会被用户当电池杀手。修改这个值前请确认 plan.md
      // 是否有同步更新。
      expect(WidgetSyncService.kWidgetCadenceFloorMin, 15);
    });

    test('host 测试环境 (非 Android / iOS) 调 syncTimeline 不抛, 不真 call channel',
        () async {
      // _supported 走 PlatformCapabilities.supportsHomeWidget, host 上是 false,
      // 所有方法应该静默 return 不 throw, 不真 call MethodChannel / HomeWidget。
      const WidgetSyncService service = WidgetSyncService();
      await service.syncTimeline(const <Quote>[], cadenceMinutes: 30);
      await service.cancelAlarm();
      await service.configure();
    });
  });
}
