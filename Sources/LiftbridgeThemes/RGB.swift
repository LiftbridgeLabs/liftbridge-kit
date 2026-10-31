import Foundation

/// An sRGB color, 0...1 per channel, with the math themes need: WCAG contrast
/// and OKLCH (lightness, chroma, hue), where changing lightness keeps a color
/// looking like the same color.
public struct RGB: Hashable, Sendable {
    public var red: Double
    public var green: Double
    public var blue: Double

    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    public init(_ hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }

    public static let white = RGB(0xFFFFFF)
    public static let black = RGB(0x000000)

    public var hex: String {
        String(format: "%02X%02X%02X", Self.byte(red), Self.byte(green), Self.byte(blue))
    }

    /// WCAG relative luminance.
    public var luminance: Double {
        0.2126 * Self.linear(red) + 0.7152 * Self.linear(green) + 0.0722 * Self.linear(blue)
    }

    /// WCAG contrast ratio, 1...21. Body text needs 4.5.
    public func contrast(with other: RGB) -> Double {
        let (a, b) = (luminance, other.luminance)
        return (max(a, b) + 0.05) / (min(a, b) + 0.05)
    }

    private static func byte(_ value: Double) -> Int { Int((min(max(value, 0), 1) * 255).rounded()) }
    private static func linear(_ c: Double) -> Double { c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4) }
    private static func gamma(_ c: Double) -> Double { c <= 0.0031308 ? c * 12.92 : 1.055 * pow(c, 1 / 2.4) - 0.055 }
}

/// OKLCH: lightness 0...1, chroma (0 is gray, ~0.37 the most vivid), hue in radians.
public struct OKLCH: Hashable, Sendable {
    public var lightness: Double
    public var chroma: Double
    public var hue: Double

    public init(lightness: Double, chroma: Double, hue: Double) {
        self.lightness = lightness
        self.chroma = chroma
        self.hue = hue
    }
}

extension RGB {
    // Björn Ottosson's OKLab, https://bottosson.github.io/posts/oklab/
    public var oklch: OKLCH {
        let r = Self.linear(red), g = Self.linear(green), b = Self.linear(blue)
        let l = cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b)
        let m = cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b)
        let s = cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b)
        let L = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
        let A = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s
        let B = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
        return OKLCH(lightness: L, chroma: hypot(A, B), hue: atan2(B, A))
    }

    /// The color as a screen shows it: each channel a whole step of 1/255.
    /// Computed colors are rounded so contrast is tested on what's displayed,
    /// and so every platform gets exactly the same values.
    public var displayed: RGB {
        RGB(red: Double(Self.byte(red)) / 255, green: Double(Self.byte(green)) / 255, blue: Double(Self.byte(blue)) / 255)
    }

    /// The color, with chroma lowered until it fits in sRGB (so the hue holds),
    /// rounded to what a screen shows.
    public init(_ lch: OKLCH) {
        let lightness = min(max(lch.lightness, 0), 1)
        var chroma = max(lch.chroma, 0)
        while chroma > 0 {
            if let rgb = Self.exact(OKLCH(lightness: lightness, chroma: chroma, hue: lch.hue)) {
                self = rgb.displayed
                return
            }
            chroma -= 0.002
        }
        self = (Self.exact(OKLCH(lightness: lightness, chroma: 0, hue: 0)) ?? .black).displayed
    }

    private static func exact(_ lch: OKLCH) -> RGB? {
        let A = lch.chroma * cos(lch.hue), B = lch.chroma * sin(lch.hue), L = lch.lightness
        let l = pow(L + 0.3963377774 * A + 0.2158037573 * B, 3)
        let m = pow(L - 0.1055613458 * A - 0.0638541728 * B, 3)
        let s = pow(L - 0.0894841775 * A - 1.2914855480 * B, 3)
        let r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
        let g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
        let b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
        let tolerance = 0.0005
        guard [r, g, b].allSatisfy({ $0 >= -tolerance && $0 <= 1 + tolerance }) else { return nil }
        return RGB(red: gamma(min(max(r, 0), 1)), green: gamma(min(max(g, 0), 1)), blue: gamma(min(max(b, 0), 1)))
    }
}
