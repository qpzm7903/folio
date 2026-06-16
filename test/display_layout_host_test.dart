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

void main() {
  group('屏保版式注册表', () {
    test('精选 5 版式 (页/满/印/时/片), key 不重复', () {
      expect(kDisplayLayouts.length, 5);
      final List<String> keys =
          kDisplayLayouts.map((DisplayLayout l) => l.key).toList();
      expect(keys, <String>[
        'page',
        'fullbleed',
        'stamped',
        'lockscreen',
        'card',
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
