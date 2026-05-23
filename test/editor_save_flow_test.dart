import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/presentation/editor/editor_screen.dart';

import 'test_harness.dart';

void main() {
  group('EditorScreen save flow', () {
    testWidgets('新建金句: 输入文字 → 收入金库 按钮可点 → repo 多一句', (
      WidgetTester tester,
    ) async {
      final FakeQuoteRepository repo = FakeQuoteRepository(<Quote>[]);
      await pumpAppWith(tester, child: const _EditorRoute(), repo: repo);
      // 让 LibraryScreen QuotesNotifier 完成 _load
      await tester.pumpAndSettle();

      // 找到 TextField 输入 hint placeholder 提示存在
      final Finder mainText = find.byType(TextField).first;
      await tester.enterText(mainText, '走得慢, 也是远行。');
      await tester.pump();

      // 找到"收入金库"按钮 (新建模式)
      final Finder save = find.text('收入金库');
      expect(save, findsOneWidget);
      await tester.tap(save);
      // SnackBar + Navigator.maybePop 触发的 frames
      await tester.pumpAndSettle();

      expect(repo.snapshot.length, 1);
      expect(repo.snapshot.single.text, '走得慢, 也是远行。');
    });

    testWidgets('编辑模式: 改文字 → 存下来 → repo 内容被替换 (id 不变)', (
      WidgetTester tester,
    ) async {
      final Quote original = testQuote(id: 'fixed', text: '旧句子', tag: '旧标签');
      final FakeQuoteRepository repo = FakeQuoteRepository(<Quote>[original]);
      await pumpAppWith(
        tester,
        child: _EditorRoute(editing: original),
        repo: repo,
      );
      await tester.pumpAndSettle();

      // 编辑模式标题应该是 "改一改"
      expect(find.text('改一改'), findsOneWidget);
      // 主输入框已经预填 "旧句子"
      expect(find.text('旧句子'), findsOneWidget);

      final Finder mainText = find.byType(TextField).first;
      await tester.enterText(mainText, '改后的句子');
      await tester.pump();

      await tester.tap(find.text('存下来'));
      await tester.pumpAndSettle();

      expect(repo.snapshot.length, 1);
      expect(repo.snapshot.single.id, 'fixed');
      expect(repo.snapshot.single.text, '改后的句子');
    });
  });
}

/// 把 EditorScreen 套到一个 Navigator 子树里, 方便 Navigator.maybePop 不崩。
class _EditorRoute extends StatelessWidget {
  const _EditorRoute({this.editing});
  final Quote? editing;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        builder: (_) => EditorScreen(editing: editing),
      ),
    );
  }
}
