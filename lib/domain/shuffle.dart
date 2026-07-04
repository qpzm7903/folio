import 'dart:math';

/// Fisher-Yates 洗牌, 返回新数组, 原数组不动。
List<T> shuffleArr<T>(List<T> arr, {Random? random}) {
  final Random rng = random ?? Random();
  final List<T> a = List<T>.of(arr);
  for (int i = a.length - 1; i > 0; i--) {
    final int j = rng.nextInt(i + 1);
    final T tmp = a[i];
    a[i] = a[j];
    a[j] = tmp;
  }
  return a;
}

/// "无重复轮播" 状态机 —— 对应 screens.jsx 里的 `useNoRepeatShuffle`。
///
/// 每一轮把所有句子都过一次, 才会重洗。重洗时避免新一轮的第 1 个和上一轮的最后
/// 一个是同一句, 防止视觉上看起来"卡住"。
///
/// 这是纯函数式状态机, 不依赖 Flutter, 方便在测试里直接驱动。
class NoRepeatShuffle {
  NoRepeatShuffle({required this.itemCount, Random? random})
      : _rng = random ?? Random(),
        _order = shuffleArr(
          List<int>.generate(itemCount, (int i) => i),
          random: random,
        ),
        _pos = 0,
        _round = 1;

  /// 从持久化快照恢复 (v0.26.0 屏保续位)。
  /// 调用方负责保证 [order] 是 0..itemCount-1 的排列且 [pos] 在界内
  /// (id→索引翻译见 domain/rotation_resume.dart)。
  NoRepeatShuffle.restore({
    required this.itemCount,
    required List<int> order,
    required int pos,
    required int round,
    Random? random,
  })  : _rng = random ?? Random(),
        _order = List<int>.of(order),
        _pos = pos,
        _round = round;

  final int itemCount;
  final Random _rng;
  List<int> _order;
  int _pos;
  int _round;

  /// 当前应该展示的 item 索引。
  int get currentIndex => _order.isEmpty ? 0 : _order[_pos % _order.length];

  /// 本轮洗牌顺序快照 (持久化用, 不可变视图)。
  List<int> get order => List<int>.unmodifiable(_order);

  /// 当前在本轮中的下标 (0 起, 持久化用; UI 语义见 [posInRound])。
  int get position => _pos;

  /// 当前是第几轮 (从 1 开始)。
  int get round => _round;

  /// 当前轮里, 已经看到第几句 (从 1 开始)。
  int get posInRound => _pos + 1;

  /// 当前轮总共多少句。
  int get totalInRound => _order.length;

  /// 前进到下一句; 如果当前轮已经走完, 自动重洗下一轮。
  void next() {
    if (_order.isEmpty) return;
    if (_pos + 1 >= _order.length) {
      final int last = _order[_pos];
      List<int> nextOrder = shuffleArr(
        List<int>.generate(itemCount, (int i) => i),
        random: _rng,
      );
      int guard = 0;
      while (nextOrder.isNotEmpty &&
          nextOrder.first == last &&
          nextOrder.length > 1 &&
          guard++ < 8) {
        nextOrder = shuffleArr(nextOrder, random: _rng);
      }
      _order = nextOrder;
      _pos = 0;
      _round++;
    } else {
      _pos++;
    }
  }

  /// 当 quotes 列表长度变化, 调用这个方法重置状态。
  void resetForNewLength(int newLength) {
    if (newLength == _order.length) return;
    _order = shuffleArr(
      List<int>.generate(newLength, (int i) => i),
      random: _rng,
    );
    _pos = 0;
    _round = 1;
  }
}
