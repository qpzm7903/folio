/// 应用版本号 —— **唯一可信源**。
///
/// 每次发布新版本时必须跟 `pubspec.yaml` 的 `version:` 字段同步,
/// `test/app_version_test.dart` 会解析 pubspec 并断言一致, 漏改任意一处
/// CI 直接红牌。
///
/// 不引入 `package_info_plus` 读取运行时版本是因为 v0.14.1 刚因
/// `home_widget` plugin 拉进 `androidx.work` 在 Android 16 上启动崩溃,
/// 教训告诉我们能用编译期常量解决的就不要加 native 插件依赖。
const String kAppVersion = '0.16.1';
