import Foundation

// The picker's text, in the app's language: the first of the app's own
// languages that the kit has too, else English. Following the app rather than
// the device keeps an English-only app from showing a German picker.
// Text the kit has no entry for (an app's own theme name) shows as given.
enum Localized {
    static func string(_ key: String, language: String? = nil) -> String {
        bundle(for: language ?? appLanguage).localizedString(forKey: key, value: key, table: nil)
    }

    /// The languages the kit's text comes in.
    static var languages: [String] { Bundle.module.localizations.filter { $0 != "Base" } }

    private static var appLanguage: String {
        Bundle.preferredLocalizations(from: languages, forPreferences: Bundle.main.preferredLocalizations).first ?? "en"
    }

    private static func bundle(for language: String) -> Bundle {
        Bundle.module.path(forResource: language, ofType: "lproj").flatMap(Bundle.init(path:)) ?? .module
    }
}

extension Theme {
    /// The name to show, in the app's language. `name` stays the English one.
    public var localizedName: String { Localized.string(name) }
}

extension ThemeGroup {
    /// The heading to show, in the app's language. `title` stays the English one.
    public var localizedTitle: String { Localized.string(title) }
}
