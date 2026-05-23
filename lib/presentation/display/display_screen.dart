import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform_capabilities.dart';
import '../../data/quote.dart';
import '../../data/settings_repository.dart';
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
/// - 底部 3 个工具按钮: shuffle / image (切换深底) / bookmark (v0.13.3 起 toggle 收藏)
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

  @override
  void dispose() {
    _rotation?.dispose();
    super.dispose();
  }

  /// 把"按句子数 + 配置频率"算出当前应有的 controller; 第一次创建, 后续 reconfigure。
  /// 在 build() 里调用安全, 因为 reconfigure 内部只在真正变化时才重起 timer,
  /// 不会因为每帧 rebuild 而疯狂 cancel/start。
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

  /// Timer 回调 —— 仅刷新 fade key, shuffle 的 next 已经在 controller 里做了。
  void _onTick() {
    if (!mounted) return;
    setState(() => _fadeKey++);
  }

  /// 用户点 shuffle: 委托给 [RotationController.advance], 它会 invoke [_onTick] 重画。
  void _advance() {
    _rotation?.advance();
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
        final Color subColor = _withPhoto
            ? const Color(0xFFF7F8ED).withValues(alpha: 0.7)
            : t.fg3;

        final String? bgPath = settings.backgroundImagePath;
        final bool hasUserBg =
            _withPhoto && bgPath != null && !PlatformCapabilities.isWeb;

        return Stack(
          children: <Widget>[
            // 背景: 用户图 > 深绿渐变 > bgPage
            if (hasUserBg)
              Positioned.fill(
                child: Image.file(
                  File(bgPath),
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext _, Object __, StackTrace? ___) =>
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

            // Protection gradient —— 用户图必须配,
            // skill README.md:110 的硬规则, 保证文字可读
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

            // Quote 内容 (淡入 + 上漂)
            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 80,
                  ),
                  child: AnimatedSwitcher(
                    duration: XJKTokens.durPage,
                    transitionBuilder: (Widget child, Animation<double> anim) {
                      final Animation<Offset> slide =
                          Tween<Offset>(
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
                        child: SlideTransition(position: slide, child: child),
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

            // 底部 3 控制
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
