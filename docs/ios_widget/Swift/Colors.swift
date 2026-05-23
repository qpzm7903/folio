// XJK design tokens → SwiftUI Color
// 跟 lib/theme/tokens.dart 同步。改动这里时同步改 Android docs/android_widget/colors_folio.xml。

import SwiftUI

extension Color {
    static let xjkBgRaised = Color(hex: 0xFBFCF3)
    static let xjkFg1 = Color(hex: 0x1D2A1F)
    static let xjkFg3 = Color(hex: 0x5E7263)
    static let xjkMark = Color(hex: 0xB8A866)
    static let xjkMarkSoft = Color(hex: 0xB8A866).opacity(0.2)
    static let xjkBorder1 = Color(hex: 0xCDD4B6)
    static let xjkLeaf700 = Color(hex: 0x4A6B35)
    static let xjkDarkQuoteBg = Color(hex: 0x2C3D27)
    static let xjkDarkQuoteText = Color(hex: 0xEDF2DC)

    init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
