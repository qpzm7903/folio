package app.folio.widget

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.SystemClock

/**
 * v0.16.0: 把"小组件按 cadence 自动换句"下沉到 AlarmManager。
 *
 * 为什么必须自己写 AlarmManager (而不是用 `AppWidgetProvider.updatePeriodMillis`):
 *   Android 系统强制 updatePeriodMillis ≥ 30 分钟, 小于这个值会被静默忽略。
 *   用户配的 cadence 是 1/5/15min, 必须 AlarmManager.setInexactRepeating
 *   自己调度才能在 doze 友好的前提下生效。
 *
 * 为什么不用 WorkManager: v0.14.1 在 HONOR MagicOS Android 16 上 WorkManager
 * 的 InitializationProvider 把整个 app process 在 Dart 启动前 SIGKILL,
 * 该入口已经在 AndroidManifest 里 `tools:node="remove"` 永久禁用, 不能回头。
 *
 * 为什么 setInexactRepeating: 不需要 SCHEDULE_EXACT_ALARM 权限 (Android 12+
 * 该权限默认拒绝, 还要用户进设置授权), inexact 模式 doze 下系统能批处理
 * 多个 alarm 一起触发省电, 唯一代价是用户配 30min 实际可能 33-35min 切。
 * 对"看金句"这种 UX 完全可接受。
 *
 * 为什么不申请 RECEIVE_BOOT_COMPLETED: 部分定制 ROM (小米/华为) 对 boot
 * receiver 有自启限制需要用户授权, UX 不如"重启后小组件静止, 等用户下次
 * 开 app 由 WidgetSyncBridge 重新 schedule"。
 */
object WidgetAlarmScheduler {

    /** AlarmManager 触发的 broadcast action, 跟 Manifest receiver 一致。 */
    const val ACTION_WIDGET_TICK = "app.folio.action.WIDGET_TICK"

    /**
     * 排程一个 inexact repeating alarm, [cadenceMinutes] 分钟一次。
     * 重复调用会用 FLAG_UPDATE_CURRENT 替换旧 PendingIntent, 不会泄漏。
     */
    fun schedule(context: Context, cadenceMinutes: Int) {
        val safeCadence = cadenceMinutes.coerceAtLeast(15)
        val intervalMillis = safeCadence.toLong() * 60_000L
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pi = buildPendingIntent(context)
        // 第一次触发延后一个 cadence, 不在 schedule() 调用瞬间立刻 tick
        // (那一瞬间 widget 刚被 onUpdate 刷过, 没必要再 advance 一次)。
        val triggerAt = SystemClock.elapsedRealtime() + intervalMillis
        am.setInexactRepeating(
            AlarmManager.ELAPSED_REALTIME,
            triggerAt,
            intervalMillis,
            pi,
        )
    }

    /** 取消已 scheduled 的 alarm (quotes 变空时调用)。 */
    fun cancel(context: Context) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        am.cancel(buildPendingIntent(context))
    }

    private fun buildPendingIntent(context: Context): PendingIntent {
        val intent = Intent(ACTION_WIDGET_TICK).apply {
            // 限定 receiver package, 防止其他 app 冒充触发我们的 widget tick。
            setPackage(context.packageName)
        }
        // FLAG_IMMUTABLE 在 Android 12+ 是强制要求 (S+); FLAG_UPDATE_CURRENT
        // 让重复 schedule 复用同一个 PendingIntent slot 不泄漏。
        return PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }
}
