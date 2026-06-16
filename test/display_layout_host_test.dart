import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/quote.dart';
import 'package:folio/presentation/display/display_layout.dart';
import 'package:folio/theme/xjk_theme_id.dart';

DisplayLayoutData _data({required bool showAttribution}) {
  return DisplayLayoutData(
    quote: Quote(
      id: 't1',
      text: '测试金句',
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

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: child))),
  );
}

void main() {
  group('屏保版式注册表', () {
    test('至少注册 1 个版式, 首项是经典居中', () {
      expect(kDisplayLayouts, isNotEmpty);
      expect(kDisplayLayouts.first, isA<ClassicCenterLayout>());
    });

    test('每个版式有稳定 key 与非空标签, key 不重复', () {
      final Set<String> keys = <String>{};
      for (final DisplayLayout layout in kDisplayLayouts) {
        expect(layout.key, isNotEmpty);
        expect(layout.nameZh, isNotEmpty);
        expect(layout.nameEn, isNotEmpty);
        expect(keys.add(layout.key), isTrue, reason: '${layout.key} 重复');
      }
    });
  });

  group('ClassicCenterLayout 渲染', () {
    testWidgets('显示金句正文', (WidgetTester tester) async {
      await _pump(
        tester,
        const ClassicCenterLayout().build(_data(showAttribution: true)),
      );
      expect(find.text('测试金句'), findsOneWidget);
    });

    testWidgets('showAttribution=true 显示出处', (WidgetTester tester) async {
      await _pump(
        tester,
        const ClassicCenterLayout().build(_data(showAttribution: true)),
      );
      expect(find.text('— 出处'), findsOneWidget);
    });

    testWidgets('showAttribution=false 隐藏出处', (WidgetTester tester) async {
      await _pump(
        tester,
        const ClassicCenterLayout().build(_data(showAttribution: false)),
      );
      expect(find.text('— 出处'), findsNothing);
      expect(find.text('测试金句'), findsOneWidget);
    });
  });
}
