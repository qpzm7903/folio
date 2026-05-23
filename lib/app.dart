import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/settings_repository.dart';
import 'l10n/generated/app_localizations.dart';
import 'presentation/display/display_screen.dart';
import 'presentation/library/library_screen.dart';
import 'presentation/providers.dart';
import 'presentation/settings/settings_screen.dart';
import 'presentation/widgets/bottom_nav.dart';
import 'presentation/widgets_preview/widgets_preview_screen.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

class FolioApp extends ConsumerWidget {
  const FolioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings settings = ref.watch(settingsProvider);
    final XJKTokens paper = XJKTokens.paper();
    final XJKTokens night = XJKTokens.night();

    ThemeMode mode;
    switch (settings.themeMode) {
      case AppThemeMode.system:
        mode = ThemeMode.system;
        break;
      case AppThemeMode.paper:
        mode = ThemeMode.light;
        break;
      case AppThemeMode.night:
        mode = ThemeMode.dark;
        break;
    }

    return MaterialApp(
      title: '小金库',
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: buildThemeData(paper, brightness: Brightness.light),
      darkTheme: buildThemeData(night, brightness: Brightness.dark),
      // locale: null 跟随系统; 系统语言不在 supportedLocales 时 fallback 到第一项 (zh)
      supportedLocales: AppL10n.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        AppL10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (BuildContext context, Widget? child) {
        final Brightness platform = MediaQuery.platformBrightnessOf(context);
        final bool isDark = resolveIsDark(settings.themeMode, platform);
        return XJKTheme(
          tokens: isDark ? night : paper,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const RootShell(),
    );
  }
}

/// 主壳 —— 4 个 tab 的 IndexedStack, 共享 [BottomNav]。
class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  XJKNavTab _current = XJKNavTab.library;

  static const List<XJKNavTab> _order = <XJKNavTab>[
    XJKNavTab.library,
    XJKNavTab.display,
    XJKNavTab.widgetsTab,
    XJKNavTab.settings,
  ];

  int get _index => _order.indexOf(_current);

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Scaffold(
      backgroundColor: t.bgPage,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _index,
          children: <Widget>[
            LibraryScreen(
              onOpenDisplay: () => setState(() => _current = XJKNavTab.display),
            ),
            const DisplayScreen(),
            const WidgetsPreviewScreen(),
            const SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: XJKBottomNav(
        current: _current,
        onChanged: (XJKNavTab tab) => setState(() => _current = tab),
      ),
    );
  }
}
