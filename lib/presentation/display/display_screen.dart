import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logger.dart';
import '../../core/platform_capabilities.dart';
import '../../data/quote.dart';
import '../../data/settings_repository.dart';
import '../../data/rotation_state_repository.dart';
import '../../data/wallpaper_service.dart';
import '../../domain/quote_display.dart';
import '../../domain/rotation_controller.dart';
import '../../domain/rotation_resume.dart';
import '../../theme/tokens.dart';
import '../providers.dart';
import '../widgets/xjk_icon.dart';
import 'display_layout.dart';
import 'display_layouts.dart';

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

  /// 当前 quotes 的 id 序 (与 controller 的索引 order 配对做持久化翻译)。
  List<String> _quoteIds = const <String>[];

  void _syncRotation(List<Quote> quotes, int cadenceMin) {
    final Duration cadence = Duration(minutes: cadenceMin.clamp(1, 60 * 24));
    _quoteIds = <String>[for (final Quote q in quotes) q.id];
    if (_rotation == null) {
      _rotation = RotationController(
        itemCount: quotes.length,
        cadence: cadence,
        onAdvance: _onTick,
        restore: _loadRestore(),
      );
      return;
    }
    _rotation!.reconfigure(newItemCount: quotes.length, newCadence: cadence);
  }

  /// 读上次的洗牌快照并翻译成当前索引; 金库内容变了续不上 → null 重洗。
  RotationRestore? _loadRestore() {
    final RotationSnapshot? snap =
        ref.read(rotationStateRepositoryProvider).load();
    if (snap == null) return null;
    final List<int>? order = mapOrderToIndices(snap.ids, _quoteIds);
    if (order == null) return null;
    return (order: order, pos: snap.pos, round: snap.round);
  }

  /// 每次换句后把洗牌状态落盘 (fire-and-forget, 失败只记日志不打扰屏保)。
  void _persistRotation() {
    final RotationController? r = _rotation;
    if (r == null || r.order.length != _quoteIds.length) return;
    final List<String> ids = <String>[
      for (final int i in r.order) _quoteIds[i],
    ];
    unawaited(
      ref
          .read(rotationStateRepositoryProvider)
          .save((ids: ids, pos: r.position, round: r.round))
          .catchError((Object e, StackTrace st) {
        AppLogger.instance.handle(e, st, 'persist rotation state');
      }),
    );
  }

  void _onTick() {
    if (!mounted) return;
    _persistRotation();
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
        _syncRotation(quotes, settings.cadenceMinutes);
        final Quote current = quotes[_rotation!.currentIndex];
        final Color textColor = _withPhoto ? const Color(0xFFF7F8ED) : t.fg1;
        final Color subColor =
            _withPhoto ? const Color(0xFFF7F8ED).withValues(alpha: 0.7) : t.fg3;

        // 当前屏保版式 (按持久化 key 查注册表, 失配兜底首项)。
        final int li = kDisplayLayouts.indexWhere(
            (DisplayLayout l) => l.key == settings.displayLayoutKey);
        final DisplayLayout layout = kDisplayLayouts[li < 0 ? 0 : li];

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
                Positioned.fill(
                  child: AnimatedContainer(
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
                      child: KeyedSubtree(
                        key: ValueKey<String>('${layout.key}-$_fadeKey'),
                        child: layout.build(
                          DisplayLayoutData(
                            quote: current.copyWith(
                              text: displayQuoteText(current.text),
                            ),
                            tokens: t,
                            textColor: textColor,
                            subColor: subColor,
                            showAttribution: settings.showAttribution,
                            onPhoto: _withPhoto,
                          ),
                        ),
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

            // 版式名 pip —— 右上角, 换版式时浮现后 1.8s 淡出。
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 18,
              child: _LayoutPip(
                key: ValueKey<String>(layout.key),
                label: '${layout.nameZh} · ${layout.nameEn}',
                color: subColor,
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
                      _LayoutGlyphButton(
                        glyph: layout.nameZh,
                        color: textColor,
                        tooltip: '换版式: ${layout.nameZh} · ${layout.nameEn}',
                        onTap: () {
                          final int cur = kDisplayLayouts.indexWhere(
                              (DisplayLayout l) => l.key == layout.key);
                          final DisplayLayout next = kDisplayLayouts[
                              (cur + 1) % kDisplayLayouts.length];
                          ref
                              .read(settingsProvider.notifier)
                              .setDisplayLayoutKey(next.key);
                        },
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

/// 底栏"换版式"按钮 —— 显示当前版式的汉字字形 (对照 skill layout-glyph),
/// 而非 SVG 图标 (注册表无对应 icon 资源)。
class _LayoutGlyphButton extends StatelessWidget {
  const _LayoutGlyphButton({
    required this.glyph,
    required this.onTap,
    required this.color,
    this.tooltip,
  });

  final String glyph;
  final VoidCallback onTap;
  final Color color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Widget button = SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Center(
            child: Text(
              glyph,
              style: TextStyle(
                fontFamily: XJKTokens.serifDisplay,
                fontSize: 18,
                height: 1,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

/// 版式名 pip —— 挂载时 (换版式触发 key 变化即重挂) 浮现, 1.8s 后淡出。
class _LayoutPip extends StatefulWidget {
  const _LayoutPip({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  State<_LayoutPip> createState() => _LayoutPipState();
}

class _LayoutPipState extends State<_LayoutPip> {
  double _opacity = 1;
  Timer? _fade;

  @override
  void initState() {
    super.initState();
    _fade = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _opacity = 0);
    });
  }

  @override
  void dispose() {
    _fade?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: XJKTokens.durSlow,
        curve: XJKTokens.easePaper,
        child: Text(
          widget.label,
          style: TextStyle(
            fontFamily: XJKTokens.sansUi,
            fontSize: 11,
            letterSpacing: 1,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}
