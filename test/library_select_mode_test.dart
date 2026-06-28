import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/presentation/library/library_screen.dart';

import 'test_harness.dart';

void main() {
  group('LibraryScreen 多选模式', () {
    Future<void> pumpLibrary(WidgetTester tester) async {
      final FakeQuoteRepository repo = FakeQuoteRepository(<Quote>[
        testQuote(id: '1', text: '光从裂痕里照进来。', tag: '完整'),
        testQuote(id: '2', text: '风也是风景。', tag: '旅程'),
      ]);
      await pumpAppWith(tester, child: const LibraryScreen(), repo: repo);
      await tester.pumpAndSettle();
    }

    testWidgets('点「多选」进入选择模式, 顶栏显示「选择金句」', (WidgetTester tester) async {
      await pumpLibrary(tester);

      await tester.tap(find.byTooltip('多选'));
      await tester.pumpAndSettle();

      expect(find.text('选择金句'), findsOneWidget);
      // 进入多选后不再显示「今天的金句」hero
      expect(find.text('今天的金句'), findsNothing);
    });

    testWidgets('勾选一张卡片显示「已选 1 句」', (WidgetTester tester) async {
      await pumpLibrary(tester);
      await tester.tap(find.byTooltip('多选'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('光从裂痕里照进来。'));
      await tester.pumpAndSettle();

      expect(find.text('已选 1 句'), findsOneWidget);
    });

    testWidgets('全选 → 已选 2 句 + 底部「取出 2 句」', (WidgetTester tester) async {
      await pumpLibrary(tester);
      await tester.tap(find.byTooltip('多选'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('全选'));
      await tester.pumpAndSettle();

      expect(find.text('已选 2 句'), findsOneWidget);
      expect(find.text('取出 2 句'), findsOneWidget);

      // 取消全选回到空选状态
      await tester.tap(find.text('取消全选'));
      await tester.pumpAndSettle();
      expect(find.text('选择金句'), findsOneWidget);
    });

    testWidgets('✕ 退出多选回到普通模式', (WidgetTester tester) async {
      await pumpLibrary(tester);
      await tester.tap(find.byTooltip('多选'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('关闭'));
      await tester.pumpAndSettle();

      expect(find.text('今天的金句'), findsOneWidget);
      expect(find.text('选择金句'), findsNothing);
    });

    testWidgets('确认取出后批量删除选中的句子', (WidgetTester tester) async {
      await pumpLibrary(tester);
      await tester.tap(find.byTooltip('多选'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('全选'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('取出 2 句'));
      await tester.pumpAndSettle();

      // 确认对话框
      expect(find.text('从金库取出这 2 句？'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, '取出'));
      await tester.runAsync(() async {
        await Future<void>.delayed(Duration.zero);
      });
      await tester.pumpAndSettle();

      // 删空后回到普通模式, 显示空金库文案
      expect(find.text('这里还很空。'), findsOneWidget);
    });
  });
}
