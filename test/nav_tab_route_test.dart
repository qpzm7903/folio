import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/router.dart';
import 'package:folio/presentation/widgets/bottom_nav.dart';

void main() {
  group('XJKNavTabRoute', () {
    test('每个 enum 值都有 path + 唯一 shellIndex', () {
      final Set<String> paths = <String>{};
      final Set<int> indices = <int>{};
      for (final XJKNavTab t in XJKNavTab.values) {
        expect(t.path, isNotEmpty);
        expect(t.path.startsWith('/'), isTrue);
        paths.add(t.path);
        indices.add(t.shellIndex);
      }
      expect(paths.length, XJKNavTab.values.length);
      expect(indices.length, XJKNavTab.values.length);
    });

    test('fromShellIndex 与 shellIndex 双向一致', () {
      for (final XJKNavTab t in XJKNavTab.values) {
        expect(XJKNavTabRoute.fromShellIndex(t.shellIndex), t);
      }
    });

    test('fromShellIndex 越界兜底到 library', () {
      expect(XJKNavTabRoute.fromShellIndex(-1), XJKNavTab.library);
      expect(XJKNavTabRoute.fromShellIndex(999), XJKNavTab.library);
    });

    test('fromLocation 匹配 prefix', () {
      expect(XJKNavTabRoute.fromLocation('/library'), XJKNavTab.library);
      expect(XJKNavTabRoute.fromLocation('/display'), XJKNavTab.display);
      expect(XJKNavTabRoute.fromLocation('/widgets'), XJKNavTab.widgetsTab);
      expect(XJKNavTabRoute.fromLocation('/settings'), XJKNavTab.settings);
      // sub 路由也算
      expect(
        XJKNavTabRoute.fromLocation('/library/something'),
        XJKNavTab.library,
      );
      // 不认识的 fallback
      expect(XJKNavTabRoute.fromLocation('/unknown'), XJKNavTab.library);
    });
  });
}
