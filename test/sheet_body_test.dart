import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/presentation/widgets/sheet_body.dart';
import 'package:folio/presentation/widgets/snack_text.dart';
import 'package:folio/theme/tokens.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    builder: (BuildContext _, Widget? c) => XJKTheme(
      tokens: XJKTokens.paper(),
      child: c ?? const SizedBox.shrink(),
    ),
    home: Scaffold(body: Builder(builder: (_) => child)),
  );
}

void main() {
  group('XJKSheetBody', () {
    testWidgets('渲染标题、副标题与内容', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const XJKSheetBody(
            title: '导出金库',
            subtitle: '把这些句子原样抄出来。',
            children: <Widget>[Text('内容区')],
          ),
        ),
      );
      expect(find.text('导出金库'), findsOneWidget);
      expect(find.text('把这些句子原样抄出来。'), findsOneWidget);
      expect(find.text('内容区'), findsOneWidget);
    });

    testWidgets('键盘弹起时底部 padding 让位 viewInsets', (WidgetTester tester) async {
      // MediaQuery 覆盖直接包在组件外层: 生产环境 sheet 在 navigator overlay
      // 中能看到 viewInsets, 但测试里 Scaffold body 会把它消费掉。
      await tester.pumpWidget(
        _wrap(
          const MediaQuery(
            data: MediaQueryData(viewInsets: EdgeInsets.only(bottom: 100)),
            child: XJKSheetBody(
              title: 't',
              subtitle: 's',
              children: <Widget>[SizedBox.shrink()],
            ),
          ),
        ),
      );
      final Padding padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(XJKSheetBody),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(
        padding.padding,
        const EdgeInsets.fromLTRB(20, 8, 20, 24 + 100),
      );
    });

    testWidgets('scrollable=true 时内容包在 SingleChildScrollView 里',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const XJKSheetBody(
            title: 't',
            subtitle: 's',
            scrollable: true,
            children: <Widget>[Text('内容区')],
          ),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(XJKSheetBody),
          matching: find.byType(SingleChildScrollView),
        ),
        findsOneWidget,
      );
    });

    testWidgets('默认不包 SingleChildScrollView', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const XJKSheetBody(
            title: 't',
            subtitle: 's',
            children: <Widget>[Text('内容区')],
          ),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(XJKSheetBody),
          matching: find.byType(SingleChildScrollView),
        ),
        findsNothing,
      );
    });
  });

  group('showText', () {
    testWidgets('弹出带文案的 SnackBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (BuildContext ctx) => ElevatedButton(
              onPressed: () =>
                  ScaffoldMessenger.of(ctx).showText('已复制 3 句到剪贴板。'),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      expect(find.widgetWithText(SnackBar, '已复制 3 句到剪贴板。'), findsOneWidget);
    });

    testWidgets('duration 参数透传给 SnackBar', (WidgetTester tester) async {
      const Duration short = Duration(milliseconds: 1200);
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (BuildContext ctx) => ElevatedButton(
              onPressed: () =>
                  ScaffoldMessenger.of(ctx).showText('已收藏。', duration: short),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      final SnackBar bar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(bar.duration, short);
    });
  });
}
