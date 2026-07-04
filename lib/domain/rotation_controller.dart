import 'dart:async';
import 'dart:math';
import 'dart:ui' show VoidCallback;

import 'shuffle.dart';

/// 把"无重复随机 + 自动 cadence 计时"绑成一个对象,
/// 让 [DisplayScreen] State 不必在 build() 里管 Timer 副作用。
///
/// 创建后立刻起一个 [Timer.periodic], 每过 [cadence] 自动 [advance] 一次。
/// 用户主动 advance() 时也会重置计时器, 让"看 N 分钟"成立, 而不是"用户刚切完就又被自动切了"。
/// 持久化恢复输入 (id 顺序已由调用方翻译成当前索引, 见 rotation_resume.dart)。
typedef RotationRestore = ({List<int> order, int pos, int round});

class RotationController {
  RotationController({
    required int itemCount,
    required Duration cadence,
    required this.onAdvance,
    Random? random,
    RotationRestore? restore,
  })  : _shuffle = _buildShuffle(itemCount, random, restore),
        _itemCount = itemCount,
        _cadence = cadence {
    _startTimer();
  }

  /// 快照有效 (长度匹配 + 位置在界内) 才续位, 否则重新洗牌。
  static NoRepeatShuffle _buildShuffle(
    int itemCount,
    Random? random,
    RotationRestore? restore,
  ) {
    final bool valid = restore != null &&
        restore.order.length == itemCount &&
        restore.pos >= 0 &&
        restore.pos < itemCount;
    if (!valid) return NoRepeatShuffle(itemCount: itemCount, random: random);
    return NoRepeatShuffle.restore(
      itemCount: itemCount,
      order: restore.order,
      pos: restore.pos,
      round: restore.round,
      random: random,
    );
  }

  final NoRepeatShuffle _shuffle;
  final VoidCallback onAdvance;

  Timer? _timer;
  int _itemCount;
  Duration _cadence;

  int get currentIndex => _shuffle.currentIndex;
  Duration get cadence => _cadence;
  int get itemCount => _itemCount;

  /// 持久化快照读数 (display_screen 在每次 advance 后落盘)。
  List<int> get order => _shuffle.order;
  int get position => _shuffle.position;
  int get round => _shuffle.round;

  /// 用户主动切句子: 切一次, 通知外部, 重置 cadence。
  void advance() {
    _shuffle.next();
    onAdvance();
    _restartTimer();
  }

  /// 数据集长度或频率变了时调用。只在确实发生变化时重起 timer。
  void reconfigure({int? newItemCount, Duration? newCadence}) {
    bool changed = false;
    if (newItemCount != null && newItemCount != _itemCount) {
      _shuffle.resetForNewLength(newItemCount);
      _itemCount = newItemCount;
      changed = true;
    }
    if (newCadence != null && newCadence != _cadence) {
      _cadence = newCadence;
      changed = true;
    }
    if (changed) _restartTimer();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  void _startTimer() {
    _timer = Timer.periodic(_cadence, (_) {
      _shuffle.next();
      onAdvance();
    });
  }

  void _restartTimer() {
    _timer?.cancel();
    _startTimer();
  }
}
