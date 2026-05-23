// 小金库 iOS widget — 三种 family 对应 Android 的小 / 中 / 大尺寸。
// 视觉跟 skill `ui_kits/android-widgets/widgets.jsx` 严格保持一致。

import SwiftUI
import WidgetKit

struct QuoteWidget: Widget {
    static let kind: String = "QuoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: QuoteProvider()) { entry in
            QuoteWidgetView(entry: entry)
        }
        .configurationDisplayName("小金库")
        .description("一句话停一停。")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct QuoteWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: QuoteEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallView(entry: entry)
        case .systemMedium:
            MediumView(entry: entry)
        case .systemLarge:
            LargeView(entry: entry)
        default:
            MediumView(entry: entry)
        }
    }
}

// 1x1 紧凑: 顶左"金"印 + 截断金句
private struct SmallView: View {
    let entry: QuoteEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Circle().fill(Color.xjkMarkSoft).frame(width: 28, height: 28)
                Text("金")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundColor(.xjkMark)
            }
            Text(entry.quote)
                .font(.system(size: 12.5, design: .serif))
                .lineSpacing(4)
                .lineLimit(4)
                .truncationMode(.tail)
                .foregroundColor(.xjkFg1)
            Spacer(minLength: 0)
        }
        .padding(14)
        .containerBackground(for: .widget) {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.xjkBgRaised)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.xjkBorder1, lineWidth: 1)
                )
        }
    }
}

// 2x1: 金句主体 + 底部 attribution + "金"印
private struct MediumView: View {
    let entry: QuoteEntry
    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.quote)
                .font(.system(size: 16, design: .serif))
                .lineSpacing(6)
                .lineLimit(3)
                .truncationMode(.tail)
                .foregroundColor(.xjkFg1)
            Spacer(minLength: 4)
            HStack {
                if !entry.tag.isEmpty {
                    Text("— \(entry.tag)")
                        .font(.system(size: 12, design: .serif).italic())
                        .foregroundColor(.xjkFg3)
                        .lineLimit(1)
                }
                Spacer()
                Text("金")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundColor(.xjkMark)
            }
        }
        .padding(18)
        .containerBackground(for: .widget) {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.xjkBgRaised)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.xjkBorder1, lineWidth: 1)
                )
        }
    }
}

// 2x2: leaf-700 → dark-quote-bg 渐变, 浅字, 跟 LibraryScreen featured card 一致
private struct LargeView: View {
    let entry: QuoteEntry
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.xjkMark.opacity(0.22))
                        .frame(width: 28, height: 28)
                    Text("金")
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .foregroundColor(.xjkMark)
                }
                Text("小金库 ·")
                    .font(.system(size: 13, design: .serif))
                    .foregroundColor(.xjkMark)
                Text("Folio")
                    .font(.system(size: 13, design: .serif).italic())
                    .foregroundColor(.xjkMark)
            }
            Spacer(minLength: 14)
            Text(entry.quote)
                .font(.system(size: 18, design: .serif))
                .lineSpacing(8)
                .lineLimit(6)
                .truncationMode(.tail)
                .foregroundColor(.xjkDarkQuoteText)
            Spacer(minLength: 6)
            if !entry.tag.isEmpty {
                Text("— \(entry.tag)")
                    .font(.system(size: 12, design: .serif).italic())
                    .foregroundColor(.xjkDarkQuoteText.opacity(0.7))
                    .lineLimit(1)
            }
        }
        .padding(22)
        .containerBackground(for: .widget) {
            LinearGradient(
                gradient: Gradient(colors: [Color.xjkLeaf700, Color.xjkDarkQuoteBg]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
