import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/presentation/library/library_screen.dart';

import 'test_harness.dart';

void main() {
  group('LibraryScreen', () {
    testWidgets('空金库时显示 libraryEmpty 文案', (WidgetTester tester) async {
      await pumpAppWith(
        tester,
        child: const LibraryScreen(),
        repo: FakeQuoteRepository(<Quote>[]),
      );
      await tester.pumpAndSettle();

      expect(find.text('这里还很空。'), findsOneWidget);
    });

    testWidgets('有金句时显示 todayQuote + 卡片', (WidgetTester tester) async {
      final FakeQuoteRepository repo = FakeQuoteRepository(<Quote>[
        testQuote(id: '1', text: '光从裂痕里照进来。', tag: '完整'),
        testQuote(id: '2', text: '风也是风景。', tag: '旅程'),
      ]);
      await pumpAppWith(tester, child: const LibraryScreen(), repo: repo);
      await tester.pumpAndSettle();

      // todayQuote 标签
      expect(find.text('今天的金句'), findsOneWidget);
      // featured 卡片显示第一句
      expect(find.text('光从裂痕里照进来。'), findsOneWidget);
      // 其余卡片显示第二句
      expect(find.text('风也是风景。'), findsOneWidget);
      // 区段标题 "你的金库"
      expect(find.text('你的金库'), findsOneWidget);
    });
  });
}
