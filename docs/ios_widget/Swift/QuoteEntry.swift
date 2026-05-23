import WidgetKit

/// 一帧 widget 数据 —— 从 App Group `group.app.folio` 共享的
/// UserDefaults 里读 `todayQuote` / `todayTag` (跟 Dart 端
/// `WidgetSyncService.syncToday` 写入的 key 严格一致)。
struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: String
    let tag: String

    static let placeholder = QuoteEntry(
        date: Date(),
        quote: "把你今天读到的一句话留下来。",
        tag: ""
    )

    /// 从 App Group UserDefaults 读最新数据; 没有时返回 placeholder。
    static func loadLatest() -> QuoteEntry {
        let defaults = UserDefaults(suiteName: "group.app.folio")
        let quote = defaults?.string(forKey: "todayQuote")?.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let tag = defaults?.string(forKey: "todayTag")?.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        if let q = quote, !q.isEmpty {
            return QuoteEntry(date: Date(), quote: q, tag: tag ?? "")
        }
        return QuoteEntry(
            date: Date(),
            quote: placeholder.quote,
            tag: ""
        )
    }
}
