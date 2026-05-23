import WidgetKit

/// 30 分钟更新一次, 跟 Android `updatePeriodMillis="1800000"` 保持一致。
/// 实际数据由 Dart 端在 quotesProvider 变化时通过 home_widget 主动推送,
/// 这里的 timeline 只是兜底刷新。
struct QuoteProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        completion(QuoteEntry.loadLatest())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
        let entry = QuoteEntry.loadLatest()
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(next))
        completion(timeline)
    }
}
