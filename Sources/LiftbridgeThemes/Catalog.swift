import Foundation

// The shared Liftbridge Labs themes. An id is saved in settings, so never
// rename one that has shipped; change the name instead. Within each group the
// most distinct themes come first: an app may show only the first few.

extension ThemeGroup {
    /// Every group, in picker order. An app adds its own look in front.
    public static let shared: [ThemeGroup] = [halloween, thanksgiving, holidays, solid, twoTone, timeless, richTones, colorVision]

    public static let halloween = ThemeGroup(id: "halloween", title: "Halloween", themes: [
        Theme("ooze", "Ooze", swatch: Swatch((0x6CB953, 0x67AC53)), accent: 0x6AB253),
        Theme("counts-cape", "Count's Cape", swatch: Swatch((0x6F1A1C, 0x60181B)), accent: 0x67191B),
        Theme("trick-or-treat", "Trick or Treat", swatch: Swatch((0xEFC881, 0xEBB370)), accent: 0xE8853A, tint: 0xEFC881),
        Theme("moonlit", "Moonlit", swatch: Swatch((0x9CA2B3, 0x80889B)), accent: 0x80889B),
        Theme("boo", "Boo", swatch: Swatch((0xA6BFD1, 0xA1C8C7)), accent: 0x7FB8B4, tint: 0xA6BFD1),
        Theme("monster-mash", "Monster Mash", swatch: Swatch((0x96B77B, 0x8AA775)), accent: 0x8AA775),
    ], season: Season(from: (10, 1), through: (10, 31)))

    public static let thanksgiving = ThemeGroup(id: "thanksgiving", title: "Thanksgiving", themes: [
        Theme("pumpkin-pie", "Pumpkin Pie", swatch: Swatch((0xE9A55B, 0xC8692B), dark: (0x3A2010, 0x6E3A16)),
              accent: 0xC8692B, tint: 0xE9A55B),
        Theme("cranberry", "Cranberry", swatch: Swatch((0xF2B8C6, 0x8E1B3A), dark: (0x2A0710, 0x5C1226)),
              accent: 0x8E1B3A, tint: 0xF2B8C6),
        Theme("sage", "Sage", swatch: Swatch((0xC9D3B6, 0x7C8F6A), dark: (0x1E241A, 0x39432F)),
              accent: 0x7C8F6A, tint: 0xC9D3B6),
        Theme("maple", "Maple", swatch: Swatch((0xE8C04A, 0xB22D1B), dark: (0x3A2E0E, 0x5E1810)),
              accent: 0xB22D1B, tint: 0xE8C04A),
        Theme("hearth", "Hearth", swatch: Swatch((0xC9A27E, 0x5B3A29), dark: (0x241812, 0x4A2E20)),
              accent: 0x5B3A29, tint: 0xC9A27E),
        Theme("apple-cider", "Apple Cider", swatch: Swatch((0xF1D9A6, 0xB07A2E), dark: (0x33260F, 0x5C4118)),
              accent: 0xB07A2E, tint: 0xF1D9A6),
    ], season: Season(from: (11, 1), through: (11, 30)))

    public static let holidays = ThemeGroup(id: "holidays", title: "Holidays", themes: [
        Theme("evergreen", "Evergreen", swatch: Swatch((0x7FB08E, 0x1F5C3F), dark: (0x102419, 0x1F4A33)),
              accent: 0x1F5C3F, tint: 0x7FB08E),
        Theme("candy-cane", "Candy Cane", swatch: Swatch((0xF4C6CB, 0xC8102E), dark: (0x2C070C, 0x6A0E1C)),
              accent: 0xC8102E, tint: 0xF4C6CB),
        Theme("snowfall", "Snowfall", swatch: Swatch((0xEAF2F8, 0x7FA3C7), dark: (0x151B22, 0x2A3E55)),
              accent: 0x7FA3C7),
        Theme("gingerbread", "Gingerbread", swatch: Swatch((0xE2B78A, 0x8B5A2B), dark: (0x2E1F12, 0x5A3A1C)),
              accent: 0x8B5A2B, tint: 0xE2B78A),
        Theme("tinsel", "Tinsel", swatch: Swatch((0xE8D9A0, 0xA8A8BC), dark: (0x2A2614, 0x3C3C4C)),
              accent: 0xC9A43A, tint: 0xA8A8BC),
        Theme("mistletoe", "Mistletoe", swatch: Swatch((0xB3243A, 0x2E6B3A), dark: (0x4A0F18, 0x1A3D22)),
              accent: 0x2E6B3A, tint: 0xB3243A),
    ], season: Season(from: (12, 1), through: (1, 5)))

    public static let solid = ThemeGroup(id: "solid", title: "Solid colors", themes: [
        Theme("harbor", "Harbor", swatch: Swatch((0x406E9A, 0x2E425C), dark: (0x10202F, 0x233E5B)), accent: 0x35587B),
        Theme("ember", "Ember", swatch: Swatch((0xC05930, 0x964324), dark: (0x341807, 0x692C18)), accent: 0xAB4E2A),
        Theme("fern", "Fern", swatch: Swatch((0x4F8A68, 0x3A6550), dark: (0x182821, 0x253F32)), accent: 0x45775C),
        Theme("plum", "Plum", swatch: Swatch((0x552862, 0x34123A), dark: (0x210624, 0x3C1D45)), accent: 0x441D4E),
        Theme("honey", "Honey", swatch: Swatch((0xFBF2BD, 0xF3D564), dark: (0x2F230A, 0x5D481E)), accent: 0xF3D564),
        Theme("peony", "Peony", swatch: Swatch((0xF0C3D5, 0xE486A8), dark: (0x2D030A, 0x5A1620)), accent: 0xE486A8),
        Theme("midnight", "Midnight", swatch: Swatch((0x2C3784, 0x19205C), dark: (0x0E153C, 0x1F2664)), accent: 0x232C70),
        Theme("pebble", "Pebble", swatch: Swatch((0xE8E8E8, 0xCACBCD), dark: (0x17191A, 0x26272B)), accent: 0xCACBCD),
    ])

    public static let twoTone = ThemeGroup(id: "two-tone", title: "Two-tone", themes: [
        Theme("daydream", "Daydream", swatch: Swatch((0xEEC4D6, 0x77C2E8), dark: (0x2B050C, 0x233E5A)),
              accent: 0x77C2E8, tint: 0xEEC4D6),
        Theme("spring-rain", "Spring Rain", swatch: Swatch((0xC9E8B1, 0x8797DF), dark: (0x1C271A, 0x1F2763)),
              accent: 0x8797DF, tint: 0xC9E8B1),
        Theme("opal", "Opal", swatch: Swatch((0xBDEAED, 0xCFA3EB), dark: (0x132127, 0x3B1D45)),
              accent: 0xCFA3EB, tint: 0xBDEAED),
        Theme("golden-hour", "Golden Hour", swatch: Swatch((0xECD1DE, 0xDCB156), dark: (0x2E061A, 0x5E401C)),
              accent: 0xDCB156, tint: 0xECD1DE),
        Theme("pine-lake", "Pine Lake", swatch: Swatch((0x508A68, 0x335964), dark: (0x182821, 0x233C46)),
              accent: 0x335964, tint: 0x508A68),
        Theme("lilac-fizz", "Lilac Fizz", swatch: Swatch((0xEDD9F9, 0xE487A9), dark: (0x210623, 0x5A1620)),
              accent: 0xE487A9, tint: 0xEDD9F9),
        Theme("citrus-grove", "Citrus Grove", swatch: Swatch((0xB6933C, 0x396324), dark: (0x2D230A, 0x29401F)),
              accent: 0x396324, tint: 0xB6933C),
        Theme("jam-session", "Jam Session", swatch: Swatch((0xDBCCB7, 0xD098B4), dark: (0x2A1D12, 0x4D2136)),
              accent: 0x8E4A8F, tint: 0xDBCCB7),
        Theme("trailhead", "Trailhead", swatch: Swatch((0x6A8336, 0x5D4326), dark: (0x1F260E, 0x412E1B)),
              accent: 0x6A8336, tint: 0x5D4326),
        Theme("acorn", "Acorn", swatch: Swatch((0x7D5C38, 0x80662A), dark: (0x2A1D10, 0x5D471E)),
              accent: 0x80662A, tint: 0x7D5C38),
        Theme("first-light", "First Light", swatch: Swatch((0xF7E2D7, 0xEAA6BF), dark: (0x341708, 0x5A1620)),
              accent: 0xEAA6BF, tint: 0xF7E2D7),
        Theme("pinstripe", "Pinstripe", swatch: Swatch((0x5D5C5F, 0x2E3884), dark: (0x17191B, 0x1F2663)),
              accent: 0x2E3884, tint: 0x5D5C5F),
    ])

    public static let timeless = ThemeGroup(id: "timeless", title: "Timeless", themes: [
        Theme("denim", "Denim", swatch: Swatch((0x3C639A, 0x273E6E), dark: (0x151C36, 0x223661)), accent: 0x315184),
        Theme("cocoa-leaf", "Cocoa Leaf", swatch: Swatch((0x6B4D2D, 0x305242), dark: (0x291D12, 0x253F32)),
              accent: 0x305242, tint: 0x6B4D2D),
        Theme("prism", "Prism", swatch: Swatch((0xB5E4F7, 0xE287A9), dark: (0x121F2E, 0x591620)),
              accent: 0xE287A9, tint: 0xB5E4F7),
        Theme("glacier", "Glacier", swatch: Swatch((0xF7F7F8, 0xB7E6F8), dark: (0x17191B, 0x243E5B)),
              accent: 0xB7E6F8),
        Theme("grapefruit", "Grapefruit", swatch: Swatch((0xF4D4D3, 0xE79E96), dark: (0x311009, 0x5D2018)),
              accent: 0xE79E96, tint: 0xF4D4D3),
        Theme("tweed", "Tweed", swatch: Swatch((0x315173, 0x473C19), dark: (0x12202D, 0x5D481E)),
              accent: 0x315173, tint: 0x473C19),
    ])

    /// Hand-picked mid-tone backgrounds (cream, slate, deep teal) rather than
    /// near-white and near-black, each with a strong frame.
    public static let richTones = ThemeGroup(id: "rich-tones", title: "Rich tones", themes: [
        Theme(id: "solstice", name: "Solstice", swatch: Swatch((0x0E4653, 0x073642), dark: (0x0E4653, 0x073642)),
              palette: Palette.given(
                  canvas: Shade(0xFDF6E3, 0x002B36), card: Shade(0xFFFBF0, 0x04303C), chip: Shade(0xEEE8D5, 0x073642),
                  hairline: Shade(0xE0D8BF, 0x0E4653), ink: Shade(0x073642, 0xEEE8D5), muted: Shade(0x52646B, 0xA2AEAE),
                  accent: Shade(0x1C669A, 0x32BFB4), onAccent: Shade(0xFFFFFF, 0x00252E))
                  .withFrame(from: Swatch((0x0E4653, 0x073642), dark: (0x0E4653, 0x073642)))),
        Theme(id: "campfire", name: "Campfire", swatch: Swatch((0xD65D0E, 0xAF3A03), dark: (0x5A3A22, 0x3C3836)),
              palette: Palette.given(
                  canvas: Shade(0xFBF1C7, 0x282828), card: Shade(0xFDF6DA, 0x32302F), chip: Shade(0xEBDBB2, 0x3C3836),
                  hairline: Shade(0xE0D0A4, 0x423D38), ink: Shade(0x3C3836, 0xEBDBB2), muted: Shade(0x64594D, 0xB9AD9C),
                  accent: Shade(0xA33603, 0xFABD2F), onAccent: Shade(0xFFFFFF, 0x282010))
                  .withFrame(from: Swatch((0xD65D0E, 0xAF3A03), dark: (0x5A3A22, 0x3C3836)))),
        Theme(id: "nightshade", name: "Nightshade", swatch: Swatch((0x6272A4, 0x44475A), dark: (0x44475A, 0x21222C)),
              palette: Palette.given(
                  canvas: Shade(0xF7F5FB, 0x282A36), card: Shade(0xFFFFFF, 0x2E3040), chip: Shade(0xE9E4F5, 0x343746),
                  hairline: Shade(0xDDD6EF, 0x3A3D4E), ink: Shade(0x282A36, 0xF8F8F2), muted: Shade(0x625E7C, 0xA9ADC8),
                  accent: Shade(0x723FD5, 0xBD93F9), onAccent: Shade(0xFFFFFF, 0x201432))
                  .withFrame(from: Swatch((0x6272A4, 0x44475A), dark: (0x44475A, 0x21222C)))),
        Theme(id: "woodland", name: "Woodland", swatch: Swatch((0x2A6F46, 0x1F4D33), dark: (0x1E3A29, 0x0F1411)),
              palette: Palette.given(
                  canvas: Shade(0xF5F8F4, 0x141A16), card: Shade(0xFFFFFF, 0x19211B), chip: Shade(0xE3ECE1, 0x202A23),
                  hairline: Shade(0xD7E0D5, 0x27322A), ink: Shade(0x1F2A22, 0xE2EBE4), muted: Shade(0x57665A, 0x94A599),
                  accent: Shade(0x2A6F46, 0x58C98A), onAccent: Shade(0xFFFFFF, 0x0A1A10))
                  .withFrame(from: Swatch((0x2A6F46, 0x1F4D33), dark: (0x1E3A29, 0x0F1411)))),
        Theme(id: "rosewood", name: "Rosewood", swatch: Swatch((0xA63E64, 0x6E2442), dark: (0x4A2232, 0x2A1A20)),
              palette: Palette.given(
                  canvas: Shade(0xFDF7F8, 0x211A1D), card: Shade(0xFFFFFF, 0x281F22), chip: Shade(0xF3E6E9, 0x2F2428),
                  hairline: Shade(0xECDADF, 0x3A2C31), ink: Shade(0x3B2B30, 0xF0E4E8), muted: Shade(0x775C63, 0xB39AA2),
                  accent: Shade(0xA63E64, 0xEB6F9B), onAccent: Shade(0xFFFFFF, 0x2A0E18))
                  .withFrame(from: Swatch((0xA63E64, 0x6E2442), dark: (0x4A2232, 0x2A1A20)))),
        Theme(id: "fjord", name: "Fjord", swatch: Swatch((0x5E81AC, 0x4C566A), dark: (0x4C566A, 0x3B4252)),
              palette: Palette.given(
                  canvas: Shade(0xF8FAFC, 0x2E3440), card: Shade(0xFFFFFF, 0x343B48), chip: Shade(0xE5E9F0, 0x3B4252),
                  hairline: Shade(0xD6DCE6, 0x3F4757), ink: Shade(0x2E3440, 0xE5E9F0), muted: Shade(0x586374, 0xB2BAC8),
                  accent: Shade(0x466488, 0x8BC2D1), onAccent: Shade(0xFFFFFF, 0x16202B))
                  .withFrame(from: Swatch((0x5E81AC, 0x4C566A), dark: (0x4C566A, 0x3B4252)))),
        Theme(id: "parchment", name: "Parchment", swatch: Swatch((0x8A6A40, 0x5A3E1E), dark: (0x3B3223, 0x17140F)),
              palette: Palette.given(
                  canvas: Shade(0xFBF6EC, 0x1D1A15), card: Shade(0xFFFAF1, 0x27231C), chip: Shade(0xF0E6D5, 0x2F2B23),
                  hairline: Shade(0xE0D3BD, 0x3A342A), ink: Shade(0x33291D, 0xECE3D4), muted: Shade(0x6C5E4A, 0xA99B87),
                  accent: Shade(0x7F582B, 0xD0A05E), onAccent: Shade(0xFFFFFF, 0x201709))
                  .withFrame(from: Swatch((0x8A6A40, 0x5A3E1E), dark: (0x3B3223, 0x17140F)))),
        Theme(id: "slate", name: "Slate", swatch: Swatch((0x2C3A5C, 0x1F2430), dark: (0x22304F, 0x12151B)),
              palette: Palette.given(
                  canvas: Shade(0xF7F8FA, 0x171A21), card: Shade(0xFFFFFF, 0x1D212A), chip: Shade(0xE8EAEF, 0x242936),
                  hairline: Shade(0xDDE0E7, 0x2B303C), ink: Shade(0x1A1E27, 0xE4E7EE), muted: Shade(0x5A6172, 0x98A0B3),
                  accent: Shade(0x1F56EE, 0x6E95FF), onAccent: Shade(0xFFFFFF, 0x0A1020))
                  .withFrame(from: Swatch((0x2C3A5C, 0x1F2430), dark: (0x22304F, 0x12151B)))),
    ])

    /// Accent and "done" colors that stay easy to tell apart with common
    /// color blindness (from the Okabe-Ito palette), on plain gray backgrounds.
    public static let colorVision = ThemeGroup(id: "color-vision", title: "Color vision", themes: [
        Theme("red-green-friendly", "Red-green friendly", swatch: Swatch((0x634D6A, 0x2B0834)), accent: 0x0072B2,
              accentOverride: Shade(0x0068A3, 0x56B4E9), success: Shade(0xA14F00, 0xE69F00), neutral: true),
        Theme("blue-yellow-friendly", "Blue-yellow friendly", swatch: Swatch((0x4B4B4B, 0x000000)), accent: 0xB3261E,
              accentOverride: Shade(0xB3261E, 0xFF8A80), success: Shade(0x00796B, 0x4DB6AC), neutral: true),
    ])
}
