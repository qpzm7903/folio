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
/// 跟 [XJKNavTab] 一一对应。
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

  static XJKNavTab tabFor(String location) {
    if (location.startsWith(display)) return XJKNavTab.display;
    if (location.startsWith(widgets)) return XJKNavTab.widgetsTab;
    if (location.startsWith(settings)) return XJKNavTab.settings;
    return XJKNavTab.library;
  }

  static String pathFor(XJKNavTab tab) {
    switch (tab) {
      case XJKNavTab.library:
        return library;
      case XJKNavTab.display:
        return display;
      case XJKNavTab.widgetsTab:
        return widgets;
      case XJKNavTab.settings:
        return settings;
    }
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
        current: _tabFromIndex(shell.currentIndex),
        onChanged: (XJKNavTab tab) {
          shell.goBranch(
            _indexFromTab(tab),
            // 二次点击当前 tab → 回到根
            initialLocation: tab == _tabFromIndex(shell.currentIndex),
          );
        },
      ),
    );
  }

  static XJKNavTab _tabFromIndex(int i) {
    switch (i) {
      case 1:
        return XJKNavTab.display;
      case 2:
        return XJKNavTab.widgetsTab;
      case 3:
        return XJKNavTab.settings;
      case 0:
      default:
        return XJKNavTab.library;
    }
  }

  static int _indexFromTab(XJKNavTab tab) {
    switch (tab) {
      case XJKNavTab.library:
        return 0;
      case XJKNavTab.display:
        return 1;
      case XJKNavTab.widgetsTab:
        return 2;
      case XJKNavTab.settings:
        return 3;
    }
  }
}
