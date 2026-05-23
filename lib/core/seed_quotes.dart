import '../data/quote.dart';

/// 首启种子数据 —— 来自 skill/ui_kits/android-app/screens.jsx 的 SEED_QUOTES。
/// 让新装的用户第一眼就看到金句的样子, 而不是一个空盒子。
List<Quote> buildSeedQuotes() {
  final DateTime now = DateTime.now();
  final List<(String, String)> raw = <(String, String)>[
    ('你在心里种下的种子，时间会帮它找出口。', '坚持与回响'),
    ('所有的执着，最终都会以你意想不到的方式，轻轻拥抱你。', '坚持与回响'),
    ('真正的强大不是没有裂痕，而是光从裂痕里照进来。', '完整而非完美'),
    ('你不必完美，你只需要真实且完整地活着。', '完整而非完美'),
    ('允许自己有时候走得慢，有时候想回头，这才是完整的人。', '完整而非完美'),
    ('走得慢的人，只要不丢失目标，也比漫无目的奔跑的人更早到达。', '旅程与抵达'),
    ('不必急着去对岸，此刻的波浪也是风景。', '旅程与抵达'),
    ('人生不是冲刺，是一场深呼吸就能继续的远行。', '旅程与抵达'),
    ('你不需要成为别人，你只需要成为自己，一个不断在完整中的自己。', '自我接纳'),
    ('接纳自己的阴影，才能拥抱真正的光明。', '自我接纳'),
  ];

  return <Quote>[
    for (int i = 0; i < raw.length; i++)
      Quote(
        id: 'seed-${i + 1}',
        text: raw[i].$1,
        tag: raw[i].$2,
        // 让种子句子在时间上前后错开 1 天, 方便 Library 上看到时序
        createdAt: now.subtract(Duration(days: raw.length - i)),
      ),
  ];
}
