import 'package:flutter/material.dart';

/// Bootstrap 阶段彻底失败时显示的兜底屏 (v0.13.1 引入)。
///
/// 用最朴素的颜色 / 字体避免任何外部资源加载 —— 这屏的整个存在
/// 意义就是 "其他初始化都失败了, 我得能渲染"。所以不引 XJKTheme,
/// 不引 SVG icon, 不引 Provider, 直接 hard-code 一份足够可读的样式。
class BootstrapErrorScreen extends StatelessWidget {
  const BootstrapErrorScreen({
    required this.error,
    required this.stack,
    super.key,
  });

  final Object error;
  final StackTrace stack;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '小金库',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF3EFE6),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  '小金库启动失败',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text('请把下方错误截图反馈给开发者:'),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      '$error\n\n$stack',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
