import Foundation

/// One color in its light-mode and dark-mode versions.
public struct Shade: Hashable, Sendable {
    public var light: RGB
    public var dark: RGB

    public init(light: RGB, dark: RGB) {
        self.light = light
        self.dark = dark
    }

    public init(_ light: UInt32, _ dark: UInt32) {
        self.init(light: RGB(light), dark: RGB(dark))
    }
}

/// The colors an app draws with. Every theme fills in all of them.
public struct Palette: Hashable, Sendable {
    /// Buttons, links, highlights.
    public var accent: Shade
    /// Text and icons drawn on an accent fill.
    public var onAccent: Shade
    /// The screen behind everything.
    public var canvas: Shade
    /// Cards and rows on the canvas.
    public var card: Shade
    /// Small filled shapes: tags, chips.
    public var chip: Shade
    /// Thin borders and dividers.
    public var hairline: Shade
    /// Main text.
    public var ink: Shade
    /// Secondary text.
    public var muted: Shade
    /// Checked off, finished, saved.
    public var success: Shade

    public init(accent: Shade, onAccent: Shade, canvas: Shade, card: Shade, chip: Shade,
                hairline: Shade, ink: Shade, muted: Shade, success: Shade) {
        self.accent = accent
        self.onAccent = onAccent
        self.canvas = canvas
        self.card = card
        self.chip = chip
        self.hairline = hairline
        self.ink = ink
        self.muted = muted
        self.success = success
    }
}

/// The round two-color swatch on a theme's card: a deep version for dark
/// mode and a bright one for light mode.
public struct Swatch: Hashable, Sendable {
    public var light: [RGB]
    public var dark: [RGB]

    public init(light: [RGB], dark: [RGB]) {
        self.light = light
        self.dark = dark
    }

    public init(_ light: (UInt32, UInt32), dark: (UInt32, UInt32)? = nil) {
        self.light = [RGB(light.0), RGB(light.1)]
        self.dark = dark.map { [RGB($0.0), RGB($0.1)] } ?? self.light
    }
}

public struct Theme: Identifiable, Hashable, Sendable {
    /// Saved in settings; never change one once it has shipped.
    public let id: String
    public let name: String
    public let swatch: Swatch
    public let palette: Palette

    /// An app's own look, with every color given.
    public init(id: String, name: String, swatch: Swatch, palette: Palette) {
        self.id = id
        self.name = name
        self.swatch = swatch
        self.palette = palette
    }

    /// A theme built from two colors: `accent` for buttons and highlights,
    /// `tint` for a light wash over the backgrounds. Each is tuned for light
    /// and dark mode so text stays readable (see `Palette.derived`).
    init(_ id: String, _ name: String, swatch: Swatch, accent: UInt32, tint: UInt32? = nil,
         accentOverride: Shade? = nil, success: Shade? = nil, neutral: Bool = false) {
        self.init(id: id, name: name, swatch: swatch,
                  palette: .derived(accent: RGB(accent), tint: RGB(tint ?? accent), accentOverride: accentOverride,
                                    success: success, neutral: neutral))
    }
}

/// When a seasonal group shows: from one month and day to another, every year.
public struct Season: Hashable, Sendable {
    public let start: (month: Int, day: Int)
    public let end: (month: Int, day: Int)

    public init(from start: (month: Int, day: Int), through end: (month: Int, day: Int)) {
        self.start = start
        self.end = end
    }

    /// Seasons are Gregorian dates, so the default ignores a device set to
    /// another calendar (Hebrew, Islamic, Persian); the time zone is still local.
    public func contains(_ date: Date, calendar: Calendar = Calendar(identifier: .gregorian)) -> Bool {
        let parts = calendar.dateComponents([.month, .day], from: date)
        let today = (parts.month ?? 1) * 100 + (parts.day ?? 1)
        let from = start.month * 100 + start.day, through = end.month * 100 + end.day
        // A season can run past New Year (Dec 1 through Jan 5).
        return from <= through ? (from...through).contains(today) : today >= from || today <= through
    }

    /// "Nov 1 – Nov 30"
    public func label(locale: Locale = .current) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let style = Date.FormatStyle(locale: locale, calendar: calendar).month(.abbreviated).day()
        func day(_ part: (month: Int, day: Int)) -> String {
            // Any year works; 2001 isn't a leap year and Feb 29 isn't used.
            calendar.date(from: DateComponents(year: 2001, month: part.month, day: part.day))!.formatted(style)
        }
        return "\(day(start)) – \(day(end))"
    }

    public static func == (lhs: Season, rhs: Season) -> Bool {
        lhs.start == rhs.start && lhs.end == rhs.end
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(start.month)
        hasher.combine(start.day)
        hasher.combine(end.month)
        hasher.combine(end.day)
    }
}

public struct ThemeGroup: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let themes: [Theme]
    /// Seasonal groups show only in season, marked "New".
    public let season: Season?

    public init(id: String, title: String, themes: [Theme], season: Season? = nil) {
        self.id = id
        self.title = title
        self.themes = themes
        self.season = season
    }
}

extension Theme {
    /// The theme for Black mode: the dark-mode canvas goes true black (OLED
    /// pixels off); cards, chips and borders sit just above black (#090909,
    /// #131313, #222222) so they still stand apart. Light mode is unchanged.
    public var black: Theme {
        Theme(id: id, name: name, swatch: swatch, palette: palette.black)
    }
}

extension Palette {
    /// Lightness and chroma for each background, light then dark. The canvas
    /// and chips carry the theme's color clearly enough to tell themes apart
    /// at a glance; cards stay close to white (or dark gray) so photos and
    /// text stay the focus.
    private static let surfaces: (canvas: Recipe, card: Recipe, chip: Recipe, hairline: Recipe) = (
        canvas: Recipe(light: (0.95, 0.045), dark: (0.2, 0.06)),
        card: Recipe(light: (0.99, 0.014), dark: (0.255, 0.06)),
        chip: Recipe(light: (0.905, 0.07), dark: (0.3, 0.07)),
        hairline: Recipe(light: (0.86, 0.06), dark: (0.36, 0.06))
    )
    /// Black mode's surfaces, untinted so Black stays as black as it can
    /// while cards still stand apart from the #000000 canvas.
    private static let blackSurfaces: (card: RGB, chip: RGB, hairline: RGB) = (
        card: RGB(0x090909), chip: RGB(0x131313), hairline: RGB(0x222222)
    )
    private static let text: (ink: Recipe, muted: Recipe) = (
        ink: Recipe(light: (0.23, 0.02), dark: (0.95, 0.015)),
        muted: Recipe(light: (0.47, 0.03), dark: (0.77, 0.025))
    )
    /// A tint at least this vivid gets the full chroma above; paler ones
    /// (pastels) get proportionally less, and a gray stays gray.
    private static let fullTint = 0.05
    private static let defaultSuccess = Shade(0x3F6212, 0x9BC26A)
    /// WCAG AA for body text.
    static let readable = 4.5

    private struct Recipe {
        let light: (lightness: Double, chroma: Double)
        let dark: (lightness: Double, chroma: Double)

        /// `strength` 0...1: how much of this recipe's chroma the tint gets.
        func shade(hue: Double, strength: Double) -> Shade {
            Shade(light: RGB(OKLCH(lightness: light.lightness, chroma: light.chroma * strength, hue: hue)),
                  dark: RGB(OKLCH(lightness: dark.lightness, chroma: dark.chroma * strength, hue: hue)))
        }
    }

    static func derived(accent: RGB, tint: RGB, accentOverride: Shade?, success: Shade?, neutral: Bool) -> Palette {
        let wash = tint.oklch
        let strength = neutral ? 0 : min(wash.chroma / fullTint, 1)
        let canvas = surfaces.canvas.shade(hue: wash.hue, strength: strength)
        let card = surfaces.card.shade(hue: wash.hue, strength: strength)
        let chip = surfaces.chip.shade(hue: wash.hue, strength: strength)
        let backgrounds = [canvas, card, chip]
        // Light mode: darkened until it reads on every background (and white
        // reads on it). Dark mode: no darker than a soft pastel, lightened
        // until it reads. Given colors only move if they wouldn't read.
        func readable(_ shade: Shade, floor: Double = 0) -> Shade {
            Shade(light: tuned(shade.light, on: backgrounds.map(\.light) + [.white], step: -0.005),
                  dark: tuned(shade.dark, on: backgrounds.map(\.dark), step: 0.005, floor: floor))
        }
        let accentShade = accentOverride.map { readable($0) } ?? readable(Shade(light: accent, dark: accent), floor: 0.72)
        let ink = text.ink.shade(hue: wash.hue, strength: strength)
        return Palette(
            accent: accentShade,
            onAccent: Shade(light: onFill(accentShade.light, ink: ink), dark: onFill(accentShade.dark, ink: ink)),
            canvas: canvas,
            card: card,
            chip: chip,
            hairline: surfaces.hairline.shade(hue: wash.hue, strength: strength),
            ink: ink,
            muted: text.muted.shade(hue: wash.hue, strength: strength),
            success: readable(success ?? defaultSuccess)
        )
    }

    /// Dark mode on true black (see `Theme.black`). Text, accent and success
    /// colors keep their dark-mode values, lightened only where one wouldn't
    /// read on the darker surfaces (an app's own palette can be anything).
    var black: Palette {
        var palette = self
        palette.canvas.dark = .black
        palette.card.dark = Self.blackSurfaces.card
        palette.chip.dark = Self.blackSurfaces.chip
        palette.hairline.dark = Self.blackSurfaces.hairline
        let backgrounds = [palette.canvas.dark, palette.card.dark, palette.chip.dark]
        for role in [\Palette.ink, \.muted, \.success] {
            palette[keyPath: role].dark = Self.tuned(palette[keyPath: role].dark, on: backgrounds, step: 0.005)
        }
        palette.accent.dark = Self.tuned(palette.accent.dark, on: backgrounds, step: 0.005)
        if palette.accent.dark != accent.dark {
            // A lightened accent reads on pure black (the canvas), so black text
            // always works on it; white or the app's dark text first if they do.
            let fill = palette.accent.dark
            palette.onAccent.dark = [RGB.white, palette.ink.light, .black]
                .first { $0.contrast(with: fill) >= Self.readable } ?? .black
        }
        return palette
    }

    /// The source color moved along lightness only (same hue) until it has
    /// readable contrast with every background.
    private static func tuned(_ color: RGB, on backgrounds: [RGB], step: Double, floor: Double = 0) -> RGB {
        var lch = color.oklch
        lch.lightness = max(lch.lightness, floor)
        var rgb = RGB(lch)
        while backgrounds.contains(where: { rgb.contrast(with: $0) < readable }), (0...1).contains(lch.lightness) {
            lch.lightness += step
            rgb = RGB(lch)
        }
        return rgb
    }

    /// White on a deep accent, the theme's darkest text on a pale one.
    private static func onFill(_ accent: RGB, ink: Shade) -> RGB {
        accent.contrast(with: .white) >= readable ? .white : ink.light
    }
}
