import Foundation
import Observation
import SwiftUI

public enum ColorMode: String, CaseIterable, Identifiable, Sendable {
    /// `black` is dark mode with true-black backgrounds, for OLED screens.
    case light, dark, black, system

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .light: "Light"
        case .dark: "Dark"
        case .black: "Black"
        case .system: "System"
        }
    }

    public var systemImage: String {
        switch self {
        case .light: "sun.max"
        case .dark: "moon"
        case .black: "moon.fill"
        case .system: "circle.lefthalf.filled"
        }
    }

    /// For `.preferredColorScheme`; nil follows the device.
    public var colorScheme: ColorScheme? {
        switch self {
        case .light: .light
        case .dark, .black: .dark
        case .system: nil
        }
    }
}

/// The chosen theme and color mode, saved on this device. Views that read
/// `theme` redraw when either changes.
@MainActor @Observable
public final class ThemeStore {
    /// The app's own look, listed first and used until the person picks another.
    public let house: Theme
    public let groups: [ThemeGroup]
    /// The chosen theme, as it should be drawn: in Black mode its dark
    /// backgrounds are true black (see `Theme.black`).
    public var theme: Theme { colorMode == .black ? chosen.black : chosen }
    private var chosen: Theme
    public var colorMode: ColorMode {
        didSet { defaults.set(colorMode.rawValue, forKey: Self.colorModeKey) }
    }

    @ObservationIgnored private let defaults: UserDefaults
    private static let themeKey = "LiftbridgeThemes.theme"
    private static let colorModeKey = "LiftbridgeThemes.colorMode"

    public init(house: Theme, groups: [ThemeGroup] = ThemeGroup.shared, defaults: UserDefaults = .standard) {
        self.house = house
        self.groups = groups
        self.defaults = defaults
        let saved = defaults.string(forKey: Self.themeKey)
        // A theme that's gone from the list falls back to the app's own look.
        chosen = groups.flatMap(\.themes).first { $0.id == saved } ?? house
        colorMode = defaults.string(forKey: Self.colorModeKey).flatMap(ColorMode.init) ?? .system
    }

    public func select(_ theme: Theme) {
        chosen = theme
        defaults.set(theme.id, forKey: Self.themeKey)
    }

    /// The groups to list on `date`: seasonal groups only in season (or while
    /// their theme is the chosen one, so it never disappears) unless
    /// `allSeasons` shows them all, and the app's look first in the first
    /// year-round group.
    public func visibleGroups(on date: Date, allSeasons: Bool = false,
                              calendar: Calendar = Calendar(identifier: .gregorian)) -> [ThemeGroup] {
        var visible = groups.filter { group in
            guard let season = group.season, !allSeasons else { return true }
            return season.contains(date, calendar: calendar) || group.themes.contains { $0.id == theme.id }
        }
        if let index = visible.firstIndex(where: { $0.season == nil }) {
            let group = visible[index]
            visible[index] = ThemeGroup(id: group.id, title: group.title, themes: [house] + group.themes)
        } else {
            visible.append(ThemeGroup(id: house.id, title: house.name, themes: [house]))
        }
        return visible
    }
}
