import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/ohos_widget_service.dart';
import 'package:folio/data/quote.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('app.folio/ohos_widget');

  group('OhosWidgetService 不变量', () {
    test('host (非鸿蒙) syncTimeline 是 no-op: 不抛, 不 call channel', () async {
      // PlatformCapabilities.isOhos 在 flutter_test host 上是 false, service
      // 应该静默 return, 绝不触碰 app.folio/ohos_widget channel (鸿蒙才注册
      // handler)。锁住这条避免非鸿蒙平台误发空 channel call。
      int calls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        calls++;
        return null;
      });

      const OhosWidgetService service = OhosWidgetService();
      await service.syncTimeline(
        <Quote>[
          Quote(id: 'a', text: '种子', tag: '', createdAt: DateTime(2026)),
        ],
        colorTheme: null,
      );

      expect(calls, 0, reason: 'isOhos=false → 不应 invoke channel');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('host 上空 quotes 调用也不抛', () async {
      const OhosWidgetService service = OhosWidgetService();
      await service.syncTimeline(const <Quote>[]);
    });
  });
}
