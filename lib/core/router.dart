import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/quote.dart';
import '../presentation/display/display_screen.dart';
import '../presentation/editor/editor_screen.dart';
import '../presentation/library/library_screen.dart';
import '../presentation/library/search_screen.dart';
import '../presentation/providers.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/tags/tags_screen.dart';
import '../presentation/widgets/bottom_nav.dart';
import '../presentation/widgets_preview/widgets_preview_screen.dart';
import '../theme/tokens.dart';

/// 4 个底部 tab 的 path —— `/library` / `/display` / `/widgets` / `/settings`,
/// 跟 [XJKNavTab] 一一对应; 加 [XJKNavTabRoute] extension 后 tab ↔ path ↔
/// shell branch index 三个角度的映射都在 [XJKNavTabRoute] 里。
class FolioRoutes {
  const FolioRoutes._();
  static const String library = '/library';
  static const String display = '/display';
  static const String widgets = '/widgets';
  static const String settings = '/settings';

  // sub routes
  static const String editorNew = '/editor';
  static const String editorEdit = '/editor/:id';
  static const String search = '/search';
  static const String tags = '/tags';
}

/// 把 tab 跟 router path / shell branch index 绑成一个权威映射。
///
/// `tabs` 字段决定 [XJKNavTab.values] 在 [StatefulShellRoute.indexedStack]
/// 里的 branch 顺序; 增 / 删 tab 时只动 enum + 这里。
extension XJKNavTabRoute on XJKNavTab {
  static const List<XJKNavTab> tabs = <XJKNavTab>[
    XJKNavTab.library,
    XJKNavTab.display,
    XJKNavTab.widgetsTab,
    XJKNavTab.settings,
  ];

  /// 对应的 go_router top-level path。
  String get path {
    switch (this) {
      case XJKNavTab.library:
        return FolioRoutes.library;
      case XJKNavTab.display:
        return FolioRoutes.display;
      case XJKNavTab.widgetsTab:
        return FolioRoutes.widgets;
      case XJKNavTab.settings:
        return FolioRoutes.settings;
    }
  }

  /// 在 [StatefulShellRoute.indexedStack] branch 列表里的下标。
  int get shellIndex => tabs.indexOf(this);

  static XJKNavTab fromShellIndex(int i) {
    if (i < 0 || i >= tabs.length) return XJKNavTab.library;
    return tabs[i];
  }

  static XJKNavTab fromLocation(String location) {
    for (final XJKNavTab t in tabs) {
      if (location.startsWith(t.path)) return t;
    }
    return XJKNavTab.library;
  }
}

/// 通过 [Ref] 让其他地方能拿到同一个 GoRouter (虽然多数时候用 context.go 即可)。
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  return _buildRouter();
});

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: FolioRoutes.library,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (BuildContext _, GoRouterState __, StatefulNavigationShell shell) {
              return _ShellScaffold(shell: shell);
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: FolioRoutes.library,
                builder: (BuildContext _, GoRouterState __) =>
                    const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: FolioRoutes.display,
                builder: (BuildContext _, GoRouterState __) =>
                    const DisplayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: FolioRoutes.widgets,
                builder: (BuildContext _, GoRouterState __) =>
                    const WidgetsPreviewScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: FolioRoutes.settings,
                builder: (BuildContext _, GoRouterState __) =>
                    const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      // Push 的子路由 (覆盖底栏)
      GoRoute(
        path: FolioRoutes.editorNew,
        builder: (BuildContext _, GoRouterState __) => const EditorScreen(),
      ),
      GoRoute(
        path: FolioRoutes.editorEdit,
        builder: (BuildContext context, GoRouterState state) {
          final String? id = state.pathParameters['id'];
          final ProviderContainer container = ProviderScope.containerOf(
            context,
          );
          final List<Quote> quotes =
              container.read(quotesProvider).asData?.value ?? const <Quote>[];
          final Quote? found = id == null
              ? null
              : quotes.where((Quote q) => q.id == id).firstOrNull;
          return EditorScreen(editing: found);
        },
      ),
      GoRoute(
        path: FolioRoutes.search,
        builder: (BuildContext _, GoRouterState __) => const SearchScreen(),
      ),
      GoRoute(
        path: FolioRoutes.tags,
        builder: (BuildContext _, GoRouterState __) => const TagsScreen(),
      ),
    ],
  );
}

/// 共享 BottomNav 的 shell scaffold。
///
/// 用 `StatefulShellRoute.indexedStack` 保留每个 tab 的 navigator 状态,
/// 切回去时不重置。
class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Scaffold(
      backgroundColor: t.bgPage,
      body: SafeArea(bottom: false, child: shell),
      bottomNavigationBar: XJKBottomNav(
        current: XJKNavTabRoute.fromShellIndex(shell.currentIndex),
        onChanged: (XJKNavTab tab) {
          shell.goBranch(
            tab.shellIndex,
            // 二次点击当前 tab → 回到根
            initialLocation:
                tab == XJKNavTabRoute.fromShellIndex(shell.currentIndex),
          );
        },
      ),
    );
  }
}
