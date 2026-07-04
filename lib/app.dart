import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'data/settings_repository.dart';
import 'l10n/generated/app_localizations.dart';
import 'presentation/providers.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';
import 'theme/xjk_theme_id.dart';

/// 根 widget。
///
/// 注意: home widget 的"启动 configure + 监听 quotes 同步" 已经移到独立的
/// [WidgetSyncBridge], 由 main() 套在 FolioApp 外层。这里只关心 router
/// + theme + l10n。
class FolioApp extends ConsumerWidget {
  const FolioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings settings = ref.watch(settingsProvider);

    // 主题装配 —— 由"选中主题的亮暗"驱动, 不再写死 paper/night 二分。
    // 跟随系统: 浅/暗默认对交给 ThemeMode.system 按平台亮度选;
    // 显式选定: 把该主题放进对应亮度槽并锁定 themeMode, 强制忽略平台亮度。
    final XJKThemeId? explicit = settings.themeMode.themeId;
    final XJKThemeId lightId;
    final XJKThemeId darkId;
    final ThemeMode mode;
    if (explicit == null) {
      lightId = XJKThemeId.lightDefault;
      darkId = XJKThemeId.darkDefault;
      mode = ThemeMode.system;
    } else if (explicit.isDark) {
      lightId = XJKThemeId.lightDefault;
      darkId = explicit;
      mode = ThemeMode.dark;
    } else {
      lightId = explicit;
      darkId = XJKThemeId.darkDefault;
      mode = ThemeMode.light;
    }

    return MaterialApp.router(
      title: '小金库',
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: buildThemeData(lightId.tokens, brightness: Brightness.light),
      darkTheme: buildThemeData(darkId.tokens, brightness: Brightness.dark),
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
        // 字号档位 (v0.27.0): 与系统缩放叠乘, 不吞掉系统无障碍设置。
        final TextScaler system = MediaQuery.textScalerOf(context);
        final double combined =
            system.scale(1.0) * settings.fontScale.factor;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(combined),
          ),
          child: XJKTheme(
            tokens: (isDark ? darkId : lightId).tokens,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      routerConfig: ref.watch(routerProvider),
    );
  }
}
