import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/presentation/widgets/confirm_delete_dialog.dart';
import 'package:folio/theme/tokens.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: XJKTheme(
      tokens: XJKTokens.paper(),
      child: Scaffold(body: Builder(builder: (_) => child)),
    ),
  );
}

void main() {
  group('showConfirmDeleteDialog', () {
    testWidgets('点"取出"返回 true', (WidgetTester tester) async {
      bool? result;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (BuildContext ctx) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showConfirmDeleteDialog(ctx);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('从金库取出这句话？'), findsOneWidget);

      await tester.tap(find.text('取出'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('点"留着"返回 false', (WidgetTester tester) async {
      bool? result;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (BuildContext ctx) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showConfirmDeleteDialog(ctx);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('留着'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });
  });
}
