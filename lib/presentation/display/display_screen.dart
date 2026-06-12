import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logger.dart';
import '../../core/platform_capabilities.dart';
import '../../data/quote.dart';
import '../../data/settings_repository.dart';
import '../../data/wallpaper_service.dart';
import '../../domain/rotation_controller.dart';
import '../../theme/tokens.dart';
import '../providers.dart';
import '../widgets/xjk_icon.dart';

/// Display —— 屏保级全屏展示, 对应 screens.jsx 的 `DisplayScreen`.
///
/// 关键行为:
/// - 无重复随机轮播 [NoRepeatShuffle]
/// - 640ms 交叉淡入 + 8px 向上漂移
/// - 顶左返回按钮 (在 IndexedStack 模式下没有路由可返回, 隐藏即可)
/// - 底部 4 个工具按钮: shuffle / image (切换深底) / bookmark (v0.13.3 收藏) /
///   download (v0.15.9 Issue #8 设为系统壁纸, 仅 Android 可见)
class DisplayScreen extends ConsumerStatefulWidget {
  const DisplayScreen({this.onBack, super.key});

  final VoidCallback? onBack;

  @override
  ConsumerState<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends ConsumerState<DisplayScreen> {
  RotationController? _rotation;
  int _fadeKey = 0;
  bool _withPhoto = false;
  bool _settingWallpaper = false;

  // 截图用的 RepaintBoundary key —— 只包背景 + quote 内容,
  // 不包按钮 row, 让设为壁纸的图不带按钮装饰。
  final GlobalKey _boundaryKey = GlobalKey();

  @override
  void dispose() {
    _rotation?.dispose();
    super.dispose();
  }

  void _syncRotation(int itemCount, int cadenceMin) {
    final Duration cadence = Duration(minutes: cadenceMin.clamp(1, 60 * 24));
    if (_rotation == null) {
      _rotation = RotationController(
        itemCount: itemCount,
        cadence: cadence,
        onAdvance: _onTick,
      );
      return;
    }
    _rotation!.reconfigure(newItemCount: itemCount, newCadence: cadence);
  }

  void _onTick() {
    if (!mounted) return;
    setState(() => _fadeKey++);
  }

  void _advance() {
    _rotation?.advance();
  }

  Future<void> _setAsWallpaper() async {
    if (_settingWallpaper) return;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final WallpaperService service = ref.read(wallpaperServiceProvider);
    setState(() => _settingWallpaper = true);
    try {
      final RenderObject? ro = _boundaryKey.currentContext?.findRenderObject();
      if (ro is! RenderRepaintBoundary) {
        throw const WallpaperFailedException('boundary not mounted yet');
      }
      await service.setWallpaperFromBoundary(ro);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 1800),
          content: Text('已设为系统主屏 + 锁屏壁纸。'),
        ),
      );
    } on WallpaperUnsupportedException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } catch (e, st) {
      AppLogger.instance.handle(e, st, 'setAsWallpaper');
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('设置壁纸失败: $e')));
    } finally {
      if (mounted) setState(() => _settingWallpaper = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    final AsyncValue<List<Quote>> async = ref.watch(quotesProvider);
    final AppSettings settings = ref.watch(settingsProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object e, StackTrace _) => Center(
        child: Text('$e', style: TextStyle(color: t.danger)),
      ),
      data: (List<Quote> quotes) {
        if (quotes.isEmpty) {
          return _displayEmpty(context);
        }
        _syncRotation(quotes.length, settings.cadenceMinutes);
        final Quote current = quotes[_rotation!.currentIndex];
        final Color textColor = _withPhoto ? const Color(0xFFF7F8ED) : t.fg1;
        final Color subColor =
            _withPhoto ? const Color(0xFFF7F8ED).withValues(alpha: 0.7) : t.fg3;

        final String? bgPath = settings.backgroundImagePath;
        final bool hasUserBg =
            _withPhoto && bgPath != null && !PlatformCapabilities.isWeb;

        // RepaintBoundary 只包背景 + 文字, 不含按钮 → 截图洁净。
        final Widget snapshotArea = RepaintBoundary(
          key: _boundaryKey,
          child: Stack(
            children: <Widget>[
              if (hasUserBg)
                Positioned.fill(
                  child: Image.file(
                    File(bgPath),
                    fit: BoxFit.cover,
                    errorBuilder:
                        (BuildContext _, Object __, StackTrace? ___) =>
                            ColoredBox(color: t.bgPage),
                  ),
                )
              else
                AnimatedContainer(
                  duration: XJKTokens.durSlow,
                  decoration: BoxDecoration(
                    gradient: _withPhoto
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[t.ink500, t.ink700, t.ink900],
                          )
                        : null,
                    color: _withPhoto ? null : t.bgPage,
                  ),
                ),
              if (hasUserBg)
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: <double>[0.0, 0.3, 0.7, 1.0],
                        colors: <Color>[
                          Color(0x80000000),
                          Color(0x00000000),
                          Color(0x00000000),
                          Color(0x80000000),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 80,
                    ),
                    child: AnimatedSwitcher(
                      duration: XJKTokens.durPage,
                      transitionBuilder:
                          (Widget child, Animation<double> anim) {
                        final Animation<Offset> slide = Tween<Offset>(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: anim,
                            curve: XJKTokens.easePaper,
                          ),
                        );
                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: slide,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        key: ValueKey<int>(_fadeKey),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            current.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: XJKTokens.serifDisplay,
                              fontSize: XJKTokens.fsQuoteHero,
                              height: XJKTokens.leadingLoose,
                              color: textColor,
                            ),
                          ),
                          if (settings.showAttribution &&
                              current.tag.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 28),
                            Text(
                              '— ${current.tag}',
                              style: TextStyle(
                                fontFamily: XJKTokens.serifItalic,
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                                color: subColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        return Stack(
          children: <Widget>[
            Positioned.fill(child: snapshotArea),

            // 顶部返回 (只在外层 push 进入时显示)
            if (widget.onBack != null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 4,
                left: 4,
                child: XJKIconButton(
                  icon: 'chevron-left',
                  onPressed: widget.onBack,
                  color: textColor,
                ),
              ),

            // 底部控制条
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).padding.bottom + 24,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: t.bgRaised.withValues(alpha: _withPhoto ? 0.3 : 0.6),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: t.border1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      XJKIconButton(
                        icon: 'shuffle',
                        onPressed: _advance,
                        color: textColor,
                        tooltip: '换一句',
                      ),
                      XJKIconButton(
                        icon: 'image',
                        onPressed: () =>
                            setState(() => _withPhoto = !_withPhoto),
                        color: textColor,
                        tooltip: '换背景',
                      ),
                      Consumer(
                        builder: (BuildContext _, WidgetRef cref, Widget? __) {
                          final Set<String> favs = cref.watch(
                            favoritesProvider,
                          );
                          final bool isFav = favs.contains(current.id);
                          return XJKIconButton(
                            icon: 'bookmark',
                            color: isFav
                                ? textColor
                                : textColor.withValues(alpha: 0.5),
                            tooltip: isFav ? '已收藏 (再点取消)' : '收藏这一句',
                            onPressed: () async {
                              final ScaffoldMessengerState messenger =
                                  ScaffoldMessenger.of(context);
                              await cref
                                  .read(favoritesProvider.notifier)
                                  .toggle(current.id);
                              if (!mounted) return;
                              messenger.showSnackBar(
                                SnackBar(
                                  duration: const Duration(milliseconds: 1200),
                                  content: Text(isFav ? '已取消收藏。' : '已收藏这一句。'),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      // v0.15.9 Issue #8: 设为系统壁纸 — 仅 Android 端显示
                      // (iOS / Web / Desktop 没对等 API)。
                      if (ref.watch(wallpaperServiceProvider).isSupported)
                        XJKIconButton(
                          icon: 'download',
                          onPressed: _settingWallpaper ? null : _setAsWallpaper,
                          color: _settingWallpaper
                              ? textColor.withValues(alpha: 0.4)
                              : textColor,
                          tooltip: _settingWallpaper ? '正在设置壁纸…' : '设为系统壁纸',
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _displayEmpty(BuildContext context) {
    final XJKTokens t = XJKTheme.of(context);
    return Center(
      child: Text(
        '金库还很空。\n先写下一句话吧。',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: XJKTokens.serifDisplay,
          fontSize: 22,
          height: 1.8,
          color: t.fg2,
        ),
      ),
    );
  }
}
