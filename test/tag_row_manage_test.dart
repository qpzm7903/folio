import 'package:flutter_test/flutter_test.dart';
import 'package:folio/domain/tag_filter.dart';
import 'package:folio/presentation/widgets/tag_row.dart';
import 'package:folio/presentation/widgets/xjk_icon.dart';

import 'test_harness.dart';

/// v0.23.0 标签管理: TagRow 的管理模式 —— 对应 screens.jsx LibraryScreen
/// `managingTags` 分支 + kit.css `.tag.manage-tag` / `.tag.removable`。
void main() {
  Finder xIcons() => find.byWidgetPredicate(
        (Widget w) => w is XJKIcon && w.name == 'x',
      );

  final List<String> tags = <String>[
    kAllTagsLabel,
    '坚持',
    '旅程',
    kUntaggedLabel,
  ];

  testWidgets('不传 onToggleManaging → 无管理入口 (向后兼容)', (
    WidgetTester tester,
  ) async {
    await pumpAppWith(
      tester,
      child: TagRow(
        tags: tags,
        active: kAllTagsLabel,
        onSelect: (String _) {},
      ),
    );
    expect(find.text('管理'), findsNothing);
    expect(xIcons(), findsNothing);
  });

  testWidgets('行末显示「管理」pill, 点击回调 onToggleManaging', (
    WidgetTester tester,
  ) async {
    bool toggled = false;
    await pumpAppWith(
      tester,
      child: TagRow(
        tags: tags,
        active: kAllTagsLabel,
        onSelect: (String _) {},
        onToggleManaging: () => toggled = true,
      ),
    );
    expect(find.text('管理'), findsOneWidget);
    await tester.tap(find.text('管理'));
    expect(toggled, isTrue);
  });

  testWidgets('管理态: pill 变「完成」, 仅具名标签带 x, 点具名标签走 onDeleteTag', (
    WidgetTester tester,
  ) async {
    String? deleted;
    String? selected;
    await pumpAppWith(
      tester,
      child: TagRow(
        tags: tags,
        active: kAllTagsLabel,
        onSelect: (String t) => selected = t,
        managing: true,
        onToggleManaging: () {},
        onDeleteTag: (String t) => deleted = t,
      ),
    );

    expect(find.text('完成'), findsOneWidget);
    expect(find.text('管理'), findsNothing);
    // 具名标签 坚持/旅程 各一个 x; 哨兵 全部/未分类 没有
    expect(xIcons(), findsNWidgets(2));

    await tester.tap(find.text('坚持'));
    expect(deleted, '坚持');
    expect(selected, isNull);
  });

  testWidgets('管理态: 哨兵「全部/未分类」仍走 onSelect, 不可删', (
    WidgetTester tester,
  ) async {
    String? deleted;
    final List<String> selected = <String>[];
    await pumpAppWith(
      tester,
      child: TagRow(
        tags: tags,
        active: '坚持',
        onSelect: selected.add,
        managing: true,
        onToggleManaging: () {},
        onDeleteTag: (String t) => deleted = t,
      ),
    );

    await tester.tap(find.text(kAllTagsLabel));
    await tester.tap(find.text(kUntaggedLabel));
    expect(selected, <String>[kAllTagsLabel, kUntaggedLabel]);
    expect(deleted, isNull);
  });

  testWidgets('非管理态: 无 x 图标, 点标签正常 onSelect', (WidgetTester tester) async {
    String? selected;
    await pumpAppWith(
      tester,
      child: TagRow(
        tags: tags,
        active: kAllTagsLabel,
        onSelect: (String t) => selected = t,
        onToggleManaging: () {},
      ),
    );
    expect(xIcons(), findsNothing);
    await tester.tap(find.text('旅程'));
    expect(selected, '旅程');
  });
}
