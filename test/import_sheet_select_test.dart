import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/presentation/import/import_sheet.dart';

import 'test_harness.dart';

/// v0.24.0 批量导入增强 —— HANDOFF 第三轮: 分句/去重/去空白 + 列表勾选保留。
void main() {
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();
  }

  testWidgets('分句去重 + 默认全选 → 全部收入金库', (WidgetTester tester) async {
    final FakeQuoteRepository repo = FakeQuoteRepository();
    await pumpAppWith(tester, child: const ImportSheet(), repo: repo);

    await tester.enterText(find.byType(TextField), '甲\n乙\n甲\n丙');
    await tester.pump();

    // 去重后识别到 3 句
    expect(find.text('3'), findsOneWidget);
    expect(find.text('全部收入金库'), findsOneWidget);

    await tester.tap(find.text('全部收入金库'));
    await settle(tester);

    expect(
      repo.snapshot.map((Quote q) => q.text).toSet(),
      <String>{'甲', '乙', '丙'},
    );
  });

  testWidgets('点行取消勾选 → 按钮变「收入 N 句」且只收入选中', (
    WidgetTester tester,
  ) async {
    final FakeQuoteRepository repo = FakeQuoteRepository();
    await pumpAppWith(tester, child: const ImportSheet(), repo: repo);

    await tester.enterText(find.byType(TextField), '甲\n乙\n丙');
    await tester.pump();

    await tester.tap(find.text('乙'));
    await tester.pump();
    expect(find.text('收入 2 句'), findsOneWidget);

    await tester.tap(find.text('收入 2 句'));
    await settle(tester);

    expect(
      repo.snapshot.map((Quote q) => q.text).toSet(),
      <String>{'甲', '丙'},
    );
  });

  testWidgets('取消后再点回 → 恢复全选', (WidgetTester tester) async {
    final FakeQuoteRepository repo = FakeQuoteRepository();
    await pumpAppWith(tester, child: const ImportSheet(), repo: repo);

    await tester.enterText(find.byType(TextField), '甲\n乙');
    await tester.pump();

    await tester.tap(find.text('乙'));
    await tester.pump();
    expect(find.text('收入 1 句'), findsOneWidget);

    await tester.tap(find.text('乙'));
    await tester.pump();
    expect(find.text('全部收入金库'), findsOneWidget);
  });

  testWidgets('全部取消勾选 → 导入按钮不可点', (WidgetTester tester) async {
    final FakeQuoteRepository repo = FakeQuoteRepository();
    await pumpAppWith(tester, child: const ImportSheet(), repo: repo);

    // '甲\n甲' 去重成一行, 同时避免 TextField 的 EditableText 全文
    // 恰好等于 '甲' 导致 find.text 命中两个 widget。
    await tester.enterText(find.byType(TextField), '甲\n甲');
    await tester.pump();
    await tester.tap(find.text('甲'));
    await tester.pump();

    expect(find.text('收入 0 句'), findsOneWidget);
    await tester.tap(find.text('收入 0 句'));
    await settle(tester);
    expect(repo.snapshot, isEmpty);
  });

  testWidgets('文本变化后勾选状态重置 → 新批次默认全选', (WidgetTester tester) async {
    final FakeQuoteRepository repo = FakeQuoteRepository();
    await pumpAppWith(tester, child: const ImportSheet(), repo: repo);

    await tester.enterText(find.byType(TextField), '甲\n乙');
    await tester.pump();
    await tester.tap(find.text('乙'));
    await tester.pump();
    expect(find.text('收入 1 句'), findsOneWidget);

    // 整体替换成含同名行「乙」的新批次: 上一批的取消不应残留
    await tester.enterText(find.byType(TextField), '乙\n丙');
    await tester.pump();
    expect(find.text('全部收入金库'), findsOneWidget);
  });
}
