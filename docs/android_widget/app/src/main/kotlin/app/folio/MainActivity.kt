package app.folio

import android.app.WallpaperManager
import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * 自定义 MainActivity, 覆盖 `flutter create` 默认生成的版本 (由
 * `tool/inject_android_widget.sh` 在 CI 阶段 copy 到位)。
 *
 * v0.15.9 Issue #8: 注册 MethodChannel `app.folio/wallpaper`, Dart 端
 * 通过它把 quote 截图设为 Android 系统壁纸 (`WallpaperManager.setBitmap`)。
 * 不引入新 plugin (v0.14.1 教训: home_widget 拉 androidx.work 在 Android 16
 * 启动崩), 自己写 platform channel 是最稳的方式。
 *
 * SET_WALLPAPER 是 install-time normal permission (Android 6+ 自动授予),
 * inject 脚本会在 AndroidManifest.xml 顶层加 `<uses-permission>` 声明。
 */
class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "app.folio/wallpaper"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setWallpaperFromFile" -> handleSetWallpaper(call, result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun handleSetWallpaper(
        call: io.flutter.plugin.common.MethodCall,
        result: MethodChannel.Result
    ) {
        try {
            val path = call.argument<String>("path")
                ?: return result.error("ARG", "missing 'path'", null)
            // flag: 1=system, 2=lock, 3=both (WallpaperManager.FLAG_SYSTEM/FLAG_LOCK)
            // 默认 3 = 同时设主屏 + 锁屏壁纸, 跟 Issue #8 用户预期一致。
            val flag = call.argument<Int>("flag")
                ?: (WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK)
            val bmp = BitmapFactory.decodeFile(path)
                ?: return result.error("DECODE", "BitmapFactory returned null for $path", null)
            val wm = WallpaperManager.getInstance(applicationContext)
            wm.setBitmap(bmp, null, true, flag)
            result.success(true)
        } catch (e: Throwable) {
            result.error("WALLPAPER_FAIL", e.message ?: e.javaClass.simpleName, null)
        }
    }
}
