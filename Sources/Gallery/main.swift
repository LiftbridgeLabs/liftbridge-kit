import Foundation
import LiftbridgeThemes

// Writes a page showing every theme in light, dark and Black mode, built from
// the same palettes apps use, and opens it. Run from the repo root:
//
//   swift run Gallery            # writes gallery.html (git-ignored) and opens it
//   swift run Gallery out.html   # writes it somewhere else

let roles: [(String, KeyPath<Palette, Shade>)] = [
    ("accent", \.accent), ("onAccent", \.onAccent), ("canvas", \.canvas), ("card", \.card), ("chip", \.chip),
    ("hairline", \.hairline), ("ink", \.ink), ("muted", \.muted), ("success", \.success),
]

@MainActor func colors(_ palette: Palette, _ mode: KeyPath<Shade, RGB>) -> [String: String] {
    Dictionary(uniqueKeysWithValues: roles.map { ($0.0, "#" + palette[keyPath: $0.1][keyPath: mode].hex) })
}

let groups: [[String: Any]] = ThemeGroup.shared.map { group in
    [
        "title": group.title,
        "season": group.season.map { $0.label(locale: Locale(identifier: "en_US")) } ?? "",
        "themes": group.themes.map { theme -> [String: Any] in
            [
                "id": theme.id,
                "name": theme.name,
                "swatch": ["light": theme.swatch.light.map { "#" + $0.hex }, "dark": theme.swatch.dark.map { "#" + $0.hex }],
                "light": colors(theme.palette, \.light),
                "dark": colors(theme.palette, \.dark),
                "black": colors(theme.black.palette, \.dark),
            ]
        },
    ]
}

let json = String(data: try JSONSerialization.data(withJSONObject: groups, options: [.sortedKeys]), encoding: .utf8)!
let count = ThemeGroup.shared.reduce(0) { $0 + $1.themes.count }
let page = template
    .replacingOccurrences(of: "__DATA__", with: json)
    .replacingOccurrences(of: "__COUNT__", with: String(count))
let out = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "gallery.html")
try page.write(to: out, atomically: true, encoding: .utf8)
print(out.path)
if CommandLine.arguments.count == 1 {
    let open = Process()
    open.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    open.arguments = [out.path]
    try open.run()
}
