package app.folio.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import app.folio.R
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * 小金库 Android 桌面小组件 provider —— 跟 lib/data/widget_sync_service.dart
 * 通过 home_widget plugin 的 SharedPreferences 共享数据 (key: todayQuote / todayTag)。
 *
 * 单一 provider 覆盖小 / 中 / 大三种尺寸: 根据 widget cell 数量动态选 layout。
 */
class QuoteWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        val quote = prefs.getString("todayQuote", null)
            ?.takeIf { it.isNotBlank() }
            ?: context.getString(R.string.widget_default_quote)
        val tag = prefs.getString("todayTag", null)?.takeIf { it.isNotBlank() }

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
}
