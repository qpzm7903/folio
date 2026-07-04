import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/domain/tag_filter.dart';
import 'package:folio/presentation/library/library_screen.dart';
import 'package:folio/presentation/widgets/tag_row.dart';

import 'test_harness.dart';

Quote _q(String id, String text, String tag, int day) => Quote(
      id: id,
      text: text,
      tag: tag,
      createdAt: DateTime(2026, 6, day),
    );

/// tag-row 里的那个文本 (跟金句卡片 meta 行的同名标签文本区分开)。
Finder _pill(String label) => find.descendant(
      of: find.byType(TagRow),
      matching: find.text(label),
    );

/// 等真实 event-loop 的 mutate (saveAll) 跑完再回来 pump。
Future<void> _settleAsync(WidgetTester tester) async {
  await tester.runAsync(() async {
    await Future<void>.delayed(Duration.zero);
  });
  await tester.pumpAndSettle();
}

/// v0.23.0 标签管理内联模式的金库集成流 —— 对应 screens.jsx LibraryScreen
/// ConfirmDialog(type: "tag") 分支: 删除标签 → 句子移到未分类, 不删句。
void main() {
  List<Quote> seed() => <Quote>[
        _q('1', '种子会找到出口。', '坚持', 3),
        _q('2', '波浪也是风景。', '旅程', 2),
        _q('3', '另一颗种子。', '坚持', 1),
      ];

  testWidgets('管理 → 删除「坚持」→ 句子归未分类, pill 换成未分类', (
    WidgetTester tester,
  ) async {
    final FakeQuoteRepository repo = FakeQuoteRepository(seed());
    await pumpAppWith(tester, child: const LibraryScreen(), repo: repo);
    await tester.pumpAndSettle();

    await tester.tap(_pill('管理'));
    await tester.pumpAndSettle();
    expect(_pill('完成'), findsOneWidget);

    await tester.tap(_pill('坚持'));
    await tester.pumpAndSettle();
    expect(find.text('删除标签「坚持」？'), findsOneWidget);
    expect(find.text('标签下的金句会移到「未分类」，不会被删除。'), findsOneWidget);

    await tester.tap(find.text('删除标签'));
    await _settleAsync(tester);

    // 句子还在, 只是 tag 清空
    expect(repo.snapshot.length, 3);
    expect(
      repo.snapshot.where((Quote q) => q.tag.trim().isEmpty).length,
      2,
    );
    // tag-row: 坚持消失, 未分类出现
    expect(_pill('坚持'), findsNothing);
    expect(_pill(kUntaggedLabel), findsOneWidget);
  });

  testWidgets('正筛选被删标签 → active 回「全部」, 整列可见', (
    WidgetTester tester,
  ) async {
    final FakeQuoteRepository repo = FakeQuoteRepository(seed());
    await pumpAppWith(tester, child: const LibraryScreen(), repo: repo);
    await tester.pumpAndSettle();

    await tester.tap(_pill('坚持'));
    await tester.pumpAndSettle();

    await tester.tap(_pill('管理'));
    await tester.pumpAndSettle();
    await tester.tap(_pill('坚持'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除标签'));
    await _settleAsync(tester);

    // 回「全部」: 旅程句仍可见 (若还筛在被删标签上会是 no-match 空态)
    expect(find.text('波浪也是风景。'), findsOneWidget);
  });

  testWidgets('弹窗取消 → 什么都不变', (WidgetTester tester) async {
    final FakeQuoteRepository repo = FakeQuoteRepository(seed());
    await pumpAppWith(tester, child: const LibraryScreen(), repo: repo);
    await tester.pumpAndSettle();

    await tester.tap(_pill('管理'));
    await tester.pumpAndSettle();
    await tester.tap(_pill('旅程'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消'));
    await _settleAsync(tester);

    expect(
      repo.snapshot.where((Quote q) => q.tag == '旅程').length,
      1,
    );
    expect(_pill('旅程'), findsOneWidget);
    // 仍在管理态
    expect(_pill('完成'), findsOneWidget);
  });

  testWidgets('「完成」退出管理态', (WidgetTester tester) async {
    final FakeQuoteRepository repo = FakeQuoteRepository(seed());
    await pumpAppWith(tester, child: const LibraryScreen(), repo: repo);
    await tester.pumpAndSettle();

    await tester.tap(_pill('管理'));
    await tester.pumpAndSettle();
    await tester.tap(_pill('完成'));
    await tester.pumpAndSettle();

    expect(_pill('管理'), findsOneWidget);
    expect(_pill('完成'), findsNothing);
  });
}
