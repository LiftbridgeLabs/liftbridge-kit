import Foundation
import Testing
@testable import LiftbridgeThemes

private let house = Theme(id: "house", name: "House", swatch: Swatch((0xB4410F, 0xF08A4B)), palette: Palette(
    accent: Shade(0xB4410F, 0xF08A4B), onAccent: Shade(0xFFFFFF, 0x16120F), canvas: Shade(0xFAF7F2, 0x16120F),
    card: Shade(0xFFFFFF, 0x241E19), chip: Shade(0xF1EADF, 0x2C251F), hairline: Shade(0xE6DED2, 0x3A322A),
    ink: Shade(0x1F1B16, 0xF6EFE6), muted: Shade(0x6B6259, 0xB9AFA3), success: Shade(0x3F6212, 0x9BC26A)))

private let allThemes = ThemeGroup.shared.flatMap(\.themes)

private func date(_ month: Int, _ day: Int) -> Date {
    Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: month, day: day, hour: 12))!
}

@Suite struct ColorMath {
    @Test func hexRoundTrips() {
        #expect(RGB(0xB4410F).hex == "B4410F")
    }

    @Test func contrastMatchesWCAG() {
        #expect(abs(RGB.white.contrast(with: .black) - 21) < 0.001)
        #expect(abs(RGB(0x777777).contrast(with: .white) - 4.48) < 0.01)
    }

    @Test func oklchRoundTrips() {
        for hex: UInt32 in [0xB4410F, 0x2E3884, 0xF3D564, 0x777777, 0x000000, 0xFFFFFF] {
            #expect(RGB(RGB(hex).oklch).hex == RGB(hex).hex)
        }
    }

    @Test func outOfGamutKeepsLightness() {
        let vivid = RGB(OKLCH(lightness: 0.6, chroma: 0.4, hue: 2))
        #expect(abs(vivid.oklch.lightness - 0.6) < 0.01)
    }
}

@Suite struct Catalog {
    @Test func idsAndNamesAreUnique() {
        #expect(Set(allThemes.map(\.id)).count == allThemes.count)
        #expect(Set(allThemes.map(\.name)).count == allThemes.count)
    }

    @Test(arguments: allThemes)
    func everyThemeIsReadable(_ theme: Theme) {
        let p = theme.palette
        for (mode, pick) in [("light", \Shade.light), ("dark", \Shade.dark)] {
            let backgrounds = [p.canvas, p.card, p.chip].map { $0[keyPath: pick] }
            for background in backgrounds {
                for (role, shade) in [("accent", p.accent), ("ink", p.ink), ("muted", p.muted), ("success", p.success)] {
                    let ratio = shade[keyPath: pick].contrast(with: background)
                    #expect(ratio >= 4.5, "\(theme.name) \(mode): \(role) on \(background.hex) is \(ratio)")
                }
            }
            let fill = p.accent[keyPath: pick]
            let ratio = p.onAccent[keyPath: pick].contrast(with: fill)
            #expect(ratio >= 4.5, "\(theme.name) \(mode): text on the accent is \(ratio)")
        }
    }

    @Test(arguments: allThemes + [house])
    func everyThemeIsReadableOnBlack(_ theme: Theme) {
        let p = theme.black.palette
        #expect(p.canvas.dark == .black)
        #expect(p.canvas.light == theme.palette.canvas.light)
        for background in [p.canvas, p.card, p.chip].map(\.dark) {
            for (role, shade) in [("accent", p.accent), ("ink", p.ink), ("muted", p.muted), ("success", p.success)] {
                let ratio = shade.dark.contrast(with: background)
                #expect(ratio >= 4.5, "\(theme.name) black: \(role) on \(background.hex) is \(ratio)")
            }
        }
    }

    /// Themes side by side in the picker must look different: their
    /// backgrounds and accents together, measured in OKLab.
    @Test func themesInAGroupLookDifferent() {
        func distance(_ a: RGB, _ b: RGB) -> Double {
            let (x, y) = (a.oklch, b.oklch)
            return hypot(x.lightness - y.lightness,
                         hypot(x.chroma * cos(x.hue) - y.chroma * cos(y.hue), x.chroma * sin(x.hue) - y.chroma * sin(y.hue)))
        }
        for group in ThemeGroup.shared {
            for (i, a) in group.themes.enumerated() {
                for b in group.themes.dropFirst(i + 1) {
                    let (p, q) = (a.palette, b.palette)
                    let look = max(distance(p.canvas.light, q.canvas.light), distance(p.canvas.dark, q.canvas.dark))
                        + distance(p.accent.light, q.accent.light)
                    #expect(look >= 0.05, "\(a.name) and \(b.name) look alike (\(look))")
                }
            }
        }
    }

    @Test func blackKeepsAnAppsOwnPaletteReadable() {
        // A house palette whose "dark" mode is light gray with dark text.
        var palette = house.palette
        palette.canvas.dark = RGB(0xB0B0B0)
        palette.card.dark = RGB(0xC0C0C0)
        palette.chip.dark = RGB(0xA8A8A8)
        palette.ink.dark = RGB(0x202020)
        palette.muted.dark = RGB(0x404040)
        palette.accent.dark = RGB(0x7A2E0A)
        let black = Theme(id: "gray", name: "Gray", swatch: house.swatch, palette: palette).black.palette
        for background in [black.canvas, black.card, black.chip].map(\.dark) {
            for shade in [black.ink, black.muted, black.accent, black.success] {
                #expect(shade.dark.contrast(with: background) >= 4.5)
            }
        }
        #expect(black.onAccent.dark.contrast(with: black.accent.dark) >= 4.5, "\(black.onAccent.dark.hex) on \(black.accent.dark.hex)")
    }

    @Test func seasonsCoverTheirMonths() {
        let halloween = ThemeGroup.halloween.season!
        #expect(halloween.contains(date(10, 1)) && halloween.contains(date(10, 31)))
        #expect(!halloween.contains(date(11, 1)))
        let holidays = ThemeGroup.holidays.season!
        #expect(holidays.contains(date(12, 24)) && holidays.contains(date(1, 5)))
        #expect(!holidays.contains(date(1, 6)) && !holidays.contains(date(11, 30)))
        #expect(ThemeGroup.thanksgiving.season!.label(locale: Locale(identifier: "en_US")) == "Nov 1 – Nov 30")
    }
}

@MainActor @Suite struct Store {
    private func store(_ defaults: UserDefaults) -> ThemeStore { ThemeStore(house: house, defaults: defaults) }

    private func freshDefaults() -> UserDefaults {
        let name = "LiftbridgeThemesTests.\(UUID().uuidString)"
        return UserDefaults(suiteName: name)!
    }

    @Test func startsWithTheHouseLookAndSystemMode() {
        let store = store(freshDefaults())
        #expect(store.theme.id == "house")
        #expect(store.colorMode == .system)
    }

    @Test func remembersTheChoice() {
        let defaults = freshDefaults()
        let first = store(defaults)
        first.select(ThemeGroup.twoTone.themes[0])
        first.colorMode = .dark
        let second = store(defaults)
        #expect(second.theme.id == ThemeGroup.twoTone.themes[0].id)
        #expect(second.colorMode == .dark)
    }

    @Test func blackModeServesTheBlackVersionOfTheChosenTheme() {
        let defaults = freshDefaults()
        let store = store(defaults)
        let fern = ThemeGroup.solid.themes[3]
        store.select(fern)
        store.colorMode = .black
        #expect(store.theme.id == fern.id)
        #expect(store.theme.palette.canvas.dark == .black)
        #expect(store.colorMode.colorScheme == .dark)
        #expect(defaults.string(forKey: "LiftbridgeThemes.colorMode") == "black")
        store.colorMode = .dark
        #expect(store.theme.palette == fern.palette)
    }

    @Test func unknownSavedThemeFallsBackToHouse() {
        let defaults = freshDefaults()
        defaults.set("retired-theme", forKey: "LiftbridgeThemes.theme")
        #expect(store(defaults).theme.id == "house")
    }

    @Test func onlyTheCurrentSeasonShows() {
        let store = store(freshDefaults())
        let october = store.visibleGroups(on: date(10, 29)).map(\.id)
        #expect(october.contains("halloween") && !october.contains("thanksgiving") && !october.contains("holidays"))
        #expect(store.visibleGroups(on: date(11, 15)).map(\.id).contains("thanksgiving"))
        #expect(store.visibleGroups(on: date(3, 1)).allSatisfy { $0.season == nil })
        #expect(store.visibleGroups(on: date(3, 1), allSeasons: true).count == ThemeGroup.shared.count)
    }

    @Test func aChosenSeasonalThemeStaysListedAfterItsSeason() {
        let store = store(freshDefaults())
        store.select(ThemeGroup.halloween.themes[0])
        #expect(store.visibleGroups(on: date(11, 15)).map(\.id).contains("halloween"))
    }

    @Test func houseLookIsFirstInTheFirstYearRoundGroup() {
        let groups = store(freshDefaults()).visibleGroups(on: date(3, 1))
        #expect(groups.first?.id == "solid")
        #expect(groups.first?.themes.first?.id == "house")
    }
}

@Suite struct Calendars {
    @Test func seasonsUseGregorianDatesWhateverTheDeviceCalendar() {
        // Oct 15, 2026 falls in a different month in the Islamic calendar.
        let october15 = date(10, 15)
        #expect(ThemeGroup.halloween.season!.contains(october15))
        #expect(!ThemeGroup.halloween.season!.contains(october15, calendar: Calendar(identifier: .islamicUmmAlQura)))
    }
}
