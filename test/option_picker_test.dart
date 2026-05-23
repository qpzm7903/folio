import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/presentation/widgets/option_picker.dart';
import 'package:folio/theme/tokens.dart';

Widget _wrap(Widget child) {
  // BottomSheet 走 root Navigator overlay, XJKTheme 必须放在
  // MaterialApp.builder 而不是 home 下, 否则 ListTile 渲染时
  // 子 widget 拿不到 tokens 会 assert 挂。
  return MaterialApp(
    builder: (BuildContext _, Widget? c) => XJKTheme(
      tokens: XJKTokens.paper(),
      child: c ?? const SizedBox.shrink(),
    ),
    home: Scaffold(body: Builder(builder: (_) => child)),
  );
}

void main() {
  group('showOptionPicker', () {
    testWidgets('点中某项后返回它的 value', (WidgetTester tester) async {
      String? result;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (BuildContext ctx) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showOptionPicker<String>(
                    context: ctx,
                    current: 'a',
                    options: const <PickerOption<String>>[
                      (value: 'a', label: '青纸'),
                      (value: 'b', label: '林夜'),
                    ],
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('青纸'), findsOneWidget);
      expect(find.text('林夜'), findsOneWidget);
      // 当前选中那项有 ✓
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('林夜'));
      await tester.pumpAndSettle();
      expect(result, 'b');
    });

    testWidgets('选项 0 个时也不崩, 立刻可关闭', (WidgetTester tester) async {
      String? result = 'sentinel';
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (BuildContext ctx) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showOptionPicker<String>(
                    context: ctx,
                    current: '',
                    options: const <PickerOption<String>>[],
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      // sheet 已 open, 没 ListTile; 点屏幕外关
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });
  });
}
