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

extension Palette {
    /// The screen's background: `canvas` at the top fading to `canvasEnd` at
    /// the bottom (flat when they're the same, and in Black mode). Top to
    /// bottom, so a bar pinned at the top drawn in `canvas` matches it.
    public var canvasGradient: LinearGradient {
        LinearGradient(colors: [canvas.color, canvasEnd.color], startPoint: .top, endPoint: .bottom)
    }
}

extension Palette {
    /// `chrome` deepening to `chromeEnd`, top to bottom: for a tall frame such
    /// as a sidebar. A header band is flat `chrome` with a `FrameFade` below.
    public var chromeGradient: LinearGradient {
        LinearGradient(colors: [chrome.color, chromeEnd.color], startPoint: .top, endPoint: .bottom)
    }

    /// `chrome` fading to clear, top to bottom: put it under a header band so
    /// the frame eases into the content instead of ending in a hard line.
    public var frameFade: LinearGradient {
        LinearGradient(colors: [chrome.color, chrome.color.opacity(0)], startPoint: .top, endPoint: .bottom)
    }
}

/// The soft bottom edge of a header band: the frame's color fading to clear
/// over the content. Place it right below a band of flat `chrome`, for
/// example `.safeAreaInset(edge: .top) { header }` then `FrameFade(palette)`
/// overlaid at the band's bottom.
public struct FrameFade: View {
    private let palette: Palette
    private let height: CGFloat

    public init(_ palette: Palette, height: CGFloat = 36) {
        self.palette = palette
        self.height = height
    }

    public var body: some View {
        Rectangle()
            .fill(palette.frameFade)
            .frame(height: height)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

extension Swatch {
    /// The swatch as drawn on a theme's card, for an app's own picker.
    public func gradient(for scheme: ColorScheme) -> LinearGradient {
        LinearGradient(colors: (scheme == .dark ? dark : light).map(\.color),
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
