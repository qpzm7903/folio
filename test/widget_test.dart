// 占位 widget 测试 —— 实际功能测试在 shuffle_test.dart / quote_serialization_test.dart 里。
//
// 这里主要是为了"占住" test/widget_test.dart 这个路径, 防止 CI 上 `flutter create`
// 自动生成的默认模板 (它引用不存在的 `MyApp`) 把 analyze 弄红。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('trivial render smoke', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('小金库'))),
      ),
    );
    expect(find.text('小金库'), findsOneWidget);
  });
}
