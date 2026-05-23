import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/quote.dart';
import '../../domain/shuffle.dart';
import '../../theme/tokens.dart';
import '../providers.dart';
import '../widgets/xjk_icon.dart';

/// Display —— 屏保级全屏展示, 对应 screens.jsx 的 `DisplayScreen`.
///
/// 关键行为:
/// - 无重复随机轮播 [NoRepeatShuffle]
/// - 640ms 交叉淡入 + 8px 向上漂移
/// - 顶左返回按钮 (在 IndexedStack 模式下没有路由可返回, 隐藏即可)
/// - 底部 3 个工具按钮: shuffle / image (切换深底) / bookmark (TODO)
class DisplayScreen extends ConsumerStatefulWidget {
  const DisplayScreen({this.onBack, super.key});

  final VoidCallback? onBack;

  @override
  ConsumerState<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends ConsumerState<DisplayScreen> {
  NoRepeatShuffle? _shuffler;
  int _fadeKey = 0;
  bool _withPhoto = false;
  Timer? _autoTimer;
  int _lastLength = 0;
  int _lastCadenceMin = 30;

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  void _ensureShuffler(int length, int cadenceMin) {
    if (_shuffler == null || length != _lastLength) {
      _shuffler = NoRepeatShuffle(itemCount: length);
      _lastLength = length;
    }
    if (cadenceMin != _lastCadenceMin) {
      _lastCadenceMin = cadenceMin;
      _restartAutoTimer(cadenceMin);
    } else {
      _autoTimer ??= _makeTimer(cadenceMin);
    }
  }

  Timer _makeTimer(int cadenceMin) {
    return Timer.periodic(
      Duration(minutes: cadenceMin.clamp(1, 60 * 24)),
      (_) => _advance(),
    );
  }

  void _restartAutoTimer(int cadenceMin) {
    _autoTimer?.cancel();
    _autoTimer = _makeTimer(cadenceMin);
  }

  void _advance() {
    setState(() {
      _shuffler?.next();
      _fadeKey++;
    });
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
        _ensureShuffler(quotes.length, settings.cadenceMinutes);
        final Quote current = quotes[_shuffler!.currentIndex];
        final Color textColor = _withPhoto ? const Color(0xFFF7F8ED) : t.fg1;
        final Color subColor = _withPhoto
            ? const Color(0xFFF7F8ED).withValues(alpha: 0.7)
            : t.fg3;

        return Stack(
          children: <Widget>[
            // 背景: photo 模式下用深绿渐变模拟; default 沿用 bgPage
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
                      XJKIconButton(
                        icon: 'bookmark',
                        onPressed: null, // v0.3 起接收藏功能
                        color: textColor.withValues(alpha: 0.4),
                        tooltip: '收藏 (即将上线)',
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
