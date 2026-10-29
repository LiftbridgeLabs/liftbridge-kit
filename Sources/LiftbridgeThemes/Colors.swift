import SwiftUI
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

extension RGB {
    public var color: Color { Color(.sRGB, red: red, green: green, blue: blue) }
}

extension Shade {
    /// A color that switches between its light and dark versions with the
    /// color mode, like a color set in an asset catalog.
    public var color: Color {
        let light = light, dark = dark
        #if canImport(UIKit)
        return Color(uiColor: UIColor { traits in
            let rgb = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: 1)
        })
        #else
        return Color(nsColor: NSColor(name: nil) { appearance in
            let rgb = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light
            return NSColor(srgbRed: rgb.red, green: rgb.green, blue: rgb.blue, alpha: 1)
        })
        #endif
    }
}

extension Swatch {
    func gradient(for scheme: ColorScheme) -> LinearGradient {
        LinearGradient(colors: (scheme == .dark ? dark : light).map(\.color),
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
