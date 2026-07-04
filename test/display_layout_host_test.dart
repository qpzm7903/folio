import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/presentation/display/display_layout.dart';
import 'package:folio/presentation/display/display_layouts.dart';
import 'package:folio/theme/xjk_theme_id.dart';

DisplayLayoutData _data(String text, {bool showAttribution = true}) {
  return DisplayLayoutData(
    quote: Quote(
      id: 't1',
      text: text,
      tag: '出处',
      createdAt: DateTime(2026, 1, 1),
    ),
    tokens: XJKThemeId.paper.tokens,
    textColor: const Color(0xFF1D2A1F),
    subColor: const Color(0xFF5E7263),
    showAttribution: showAttribution,
    onPhoto: false,
  );
}

/// 同 [_data] 但 quote 无标签 (tag 空) —— 锁 _attributionLine 的"无标签不渲染"分支。
DisplayLayoutData _dataNoTag(String text) {
  return DisplayLayoutData(
    quote: Quote(id: 't1', text: text, tag: '', createdAt: DateTime(2026, 1, 1)),
    tokens: XJKThemeId.paper.tokens,
    textColor: const Color(0xFF1D2A1F),
    subColor: const Color(0xFF5E7263),
    showAttribution: true,
    onPhoto: false,
  );
}

void main() {
  group('屏保版式注册表', () {
    test('全部 9 版式, 顺序对照设计源 LAYOUTS, key 不重复', () {
      expect(kDisplayLayouts.length, 9);
      final List<String> keys =
          kDisplayLayouts.map((DisplayLayout l) => l.key).toList();
      // v0.25.0: 补齐 竖/引/条/织, 顺序对照 display-layouts.jsx 的 LAYOUTS。
      expect(keys, <String>[
        'page',
        'vertical',
        'pull',
        'lockscreen',
        'fullbleed',
        'stamped',
        'ribbon',
        'card',
        'interleave',
      ]);
      expect(keys.toSet().length, keys.length, reason: 'key 必须唯一');
    });

    test('每个版式有非空中英文名', () {
      for (final DisplayLayout l in kDisplayLayouts) {
        expect(l.nameZh, isNotEmpty);
        expect(l.nameEn, isNotEmpty);
      }
    });

    testWidgets('每个版式都能渲染出金句内容且不报错', (WidgetTester tester) async {
      for (final DisplayLayout l in kDisplayLayouts) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: l.build(_data('测试金句内容'))),
          ),
        );
        expect(
          find.textContaining('内容'),
          findsWidgets,
          reason: '${l.key} 应渲染出金句内容',
        );
        // 卸载以取消 Lockscreen 等版式的定时器, 避免 pending timer。
        await tester.pumpWidget(const SizedBox());
      }
    });
  });

  group('版式落款 (满/时 共用 _attributionLine, v0.22.1 去重)', () {
    DisplayLayout byKey(String k) =>
        kDisplayLayouts.firstWhere((DisplayLayout l) => l.key == k);

    testWidgets('满版式 showAttribution 渲染 "— 出处"', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: byKey('fullbleed').build(_data('内容')))),
      );
      expect(find.text('— 出处'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('时版式 showAttribution 渲染 "— 出处"', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: byKey('lockscreen').build(_data('内容'))),
        ),
      );
      expect(find.text('— 出处'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('showAttribution=false 时不渲染落款', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: byKey('fullbleed').build(_data('内容', showAttribution: false)),
          ),
        ),
      );
      expect(find.text('— 出处'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('showAttribution=true 但无标签时不渲染落款', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: byKey('fullbleed').build(_dataNoTag('内容')),
          ),
        ),
      );
      expect(find.textContaining('—'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('句长分级 q-scale (对照 kit.css)', () {
    test('tier 阈值正确', () {
      expect(lengthTier('一' * 10), QuoteLengthTier.tiny);
      expect(lengthTier('一' * 18), QuoteLengthTier.short);
      expect(lengthTier('一' * 30), QuoteLengthTier.medium);
      expect(lengthTier('一' * 46), QuoteLengthTier.long);
      expect(lengthTier('一' * 47), QuoteLengthTier.xlong);
    });

    test('乘子映射: 短句放大 / 长句缩小', () {
      expect(qScale('一' * 8), 1.15);
      expect(qScale('一' * 15), 1.0);
      expect(qScale('一' * 25), 0.82);
      expect(qScale('一' * 40), 0.64);
      expect(qScale('一' * 80), 0.5);
    });

    test('emoji / 多码位也按 runes 计数', () {
      // 5 个 emoji = 5 runes → tiny
      expect(lengthTier('😀😀😀😀😀'), QuoteLengthTier.tiny);
    });
  });
}
