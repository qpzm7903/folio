package app.folio.widget

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent

/**
 * v0.16.0: AlarmManager 触发的 BroadcastReceiver, 推进 timeline cursor 一格,
 * 然后让 [QuoteWidgetProvider.onUpdate] 重新渲染所有 widget 实例。
 *
 * 跟 [WidgetAlarmScheduler] 一对出现。Manifest 必须把这个 receiver 注册到
 * intent-filter `app.folio.action.WIDGET_TICK`, 否则 alarm 触发后无人响应。
 *
 * 注意 cursor 写回的是 home_widget plugin 自己的 SharedPreferences
 * (key = "HomeWidgetPreferences"), Dart 端调 HomeWidget.saveWidgetData 落到
 * 同一个 store。这里直接复用 plugin 内部 prefs 而不是自己开一个, 是为了
 * 让 Dart 端能读到最新 cursor 做 sync 决策时不会"两套真相"。
 */
class QuoteWidgetAlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != WidgetAlarmScheduler.ACTION_WIDGET_TICK) return

        val prefs = es.antonborri.home_widget.HomeWidgetPlugin.getData(context)
        // timeline 长度: 用 cursor mod length 推进, length 来自 timelineJson
        // 字符 `{` 出现次数 (每条 quote 一个 JSON object) — 比再解析 JSON 便宜,
        // 且只用于 mod 边界, 不用于渲染。
        val timelineJson = prefs.getString("widgetTimeline", null) ?: return
        if (timelineJson.isEmpty()) return
        val length = timelineJson.count { it == '{' }
        if (length <= 0) return

        // cursor 走 String 存 (避免 home_widget plugin 跨平台 int 类型差异),
        // toIntOrNull 容错任何脏数据。
        val cursor = prefs.getString("widgetTimelineCursor", "0")?.toIntOrNull() ?: 0
        val nextCursor = (cursor + 1) % length
        prefs.edit().putString("widgetTimelineCursor", nextCursor.toString()).apply()

        // 触发所有 QuoteWidgetProvider 实例重新 onUpdate 读新 cursor 渲染。
        // 直接发系统级 APPWIDGET_UPDATE intent 并限定 component, 避免影响其他
        // app 的 widget。
        val mgr = AppWidgetManager.getInstance(context)
        val component = ComponentName(context, QuoteWidgetProvider::class.java)
        val ids = mgr.getAppWidgetIds(component)
        if (ids.isEmpty()) return
        val updateIntent = Intent(AppWidgetManager.ACTION_APPWIDGET_UPDATE).apply {
            setComponent(component)
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        }
        context.sendBroadcast(updateIntent)
    }
}
