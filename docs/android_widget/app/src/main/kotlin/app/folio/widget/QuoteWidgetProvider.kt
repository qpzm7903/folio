package app.folio.widget

import android.app.Activity
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.net.Uri
import android.widget.RemoteViews
import app.folio.R
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import org.json.JSONArray

/**
 * 小金库 Android 桌面小组件 provider —— 跟 lib/data/widget_sync_service.dart
 * 通过 home_widget plugin 的 SharedPreferences 共享数据。
 *
 * 单一 provider 覆盖小 / 中 / 大三种尺寸: 根据 widget cell 数量动态选 layout。
 *
 * v0.15.5 Issue #6 子任务 3: 点击 widget 启动 app 到 /display (屏保) 路径,
 * 用户能立即看到金句轮播 / 手动切换。
 *
 * v0.16.0: 数据源从静态 `todayQuote` 改成 `widgetTimeline` JSON +
 * `widgetTimelineCursor` index 推进。Dart 端预生成 N=20 条 (NoRepeatShuffle 顺序),
 * native AlarmManager (`QuoteWidgetAlarmReceiver` + `WidgetAlarmScheduler`) 按用户
 * 配的 cadence 推 cursor。todayQuote / todayTag 作为兼容字段保留, 当 timeline
 * 缺失或解析失败时 fallback。
 */
class QuoteWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = es.antonborri.home_widget.HomeWidgetPlugin.getData(context)

        // v0.16.0: 优先从 timeline[cursor] 读; 解析失败 / 缺数据回落 todayQuote。
        val (quote, tag) = readCurrentEntry(prefs)
            ?: Pair(
                prefs.getString("todayQuote", null)
                    ?.takeIf { it.isNotBlank() }
                    ?: context.getString(R.string.widget_default_quote),
                prefs.getString("todayTag", null)?.takeIf { it.isNotBlank() },
            )

        // v0.15.7 Issue #6 子任务 4: 读 widgetColorTheme 选 background drawable;
        // 未知值 / null → paper (默认浅底)。
        val bgDrawable = when (prefs.getString("widgetColorTheme", null)) {
            "night" -> R.drawable.xjk_widget_bg_dark
            "bamboo" -> R.drawable.xjk_widget_bg_bamboo
            else -> R.drawable.xjk_widget_bg_light
        }

        // 点击 widget root → 启动 app MainActivity, URI scheme 让 Dart 端
        // 跳到 /display 路径; HomeWidgetLaunchIntent 内部已处理 API 23+ 强制
        // 要求的 PendingIntent.FLAG_IMMUTABLE 兼容性, 不要手撸。
        //
        // Class.forName 返回 Class<*>, Kotlin 推不出 getActivity<T : Activity>
        // 的 T, 必须显式 cast 成 Class<Activity>。
        @Suppress("UNCHECKED_CAST")
        val mainActivityClass = Class.forName("${context.packageName}.MainActivity")
            as Class<Activity>
        val clickIntent: PendingIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            mainActivityClass,
            Uri.parse("folio://display")
        )

        for (id in appWidgetIds) {
            val opts = appWidgetManager.getAppWidgetOptions(id)
            val minWidthDp = opts.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 180)
            val minHeightDp = opts.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 80)

            val layoutId = when {
                // 2x2 及以上 → large
                minWidthDp >= 250 && minHeightDp >= 200 -> R.layout.quote_widget_large
                // 高度小但宽 → medium
                minWidthDp >= 250 -> R.layout.quote_widget_medium
                // 1x1 紧凑 → small
                else -> R.layout.quote_widget_small
            }

            val views = RemoteViews(context.packageName, layoutId).apply {
                setTextViewText(R.id.widget_quote, quote)
                if (tag != null && layoutId != R.layout.quote_widget_small) {
                    setTextViewText(R.id.widget_tag, "— $tag")
                }
                setInt(R.id.widget_root, "setBackgroundResource", bgDrawable)
                setOnClickPendingIntent(R.id.widget_root, clickIntent)
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle
    ) {
        // 用户拖拽改大小后, 重新触发一次 onUpdate
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId))
    }

    override fun onDisabled(context: Context) {
        // 最后一个 widget 实例被移除时, 取消 alarm 不再空转。
        WidgetAlarmScheduler.cancel(context)
        super.onDisabled(context)
    }

    /**
     * 从 prefs 读 timeline JSON + cursor, 返回当前应展示的 (text, tag) 对。
     * 任何解析失败 / 空数据返回 null 让调用方回落 todayQuote 兼容字段。
     */
    private fun readCurrentEntry(
        prefs: android.content.SharedPreferences,
    ): Pair<String, String?>? {
        val json = prefs.getString("widgetTimeline", null)
            ?.takeIf { it.isNotBlank() }
            ?: return null
        return try {
            val arr = JSONArray(json)
            if (arr.length() == 0) return null
            val cursor = (prefs.getString("widgetTimelineCursor", "0")
                ?.toIntOrNull() ?: 0).coerceAtLeast(0) % arr.length()
            val item = arr.getJSONObject(cursor)
            val q = item.optString("q", "").takeIf { it.isNotBlank() } ?: return null
            val s = item.optString("s", "").takeIf { it.isNotBlank() }
            Pair(q, s)
        } catch (_: Throwable) {
            null
        }
    }
}
