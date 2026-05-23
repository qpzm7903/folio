import WidgetKit
import SwiftUI

@main
struct QuoteWidgetBundle: WidgetBundle {
    var body: some Widget {
        QuoteWidget()
        // 锁屏 widget (accessoryRectangular / accessoryCircular) 留作下个 PATCH。
    }
}
