# Liftbridge Kit

Shared code for Liftbridge Labs apps. Each library is a separate Swift package product, so an app adds only the ones it uses.

| Library | What it does |
| --- | --- |
| `LiftbridgeThemes` | Light / Dark / Black / System color mode (Black is true black for OLED screens, with any theme) and a picker of named color themes, grouped (solid colors, two-tone, timeless, color vision), with seasonal sets that appear in season marked "New". Every theme is tuned for light and dark mode so text and buttons stay readable. |

Requires iOS 18 or tvOS 18 (macOS 15 for running the tests). `ThemePicker` is for iPhone, iPad and Mac; a TV app builds its own picker for the remote from `ThemeStore` (`visibleGroups(on:)`, `select(_:)`, `colorMode`) and `Swatch.gradient(for:)`.

## Add it to an app

**XcodeGen** (`project.yml`):

```yaml
packages:
  LiftbridgeKit:
    url: https://github.com/LiftbridgeLabs/liftbridge-kit
    from: 2.0.0

targets:
  MyApp:
    dependencies:
      - package: LiftbridgeKit
        product: LiftbridgeThemes
```

Add the same dependency to any extension that compiles the file holding the app's colors.

**Plain Xcode:** File > Add Package Dependencies, paste `https://github.com/LiftbridgeLabs/liftbridge-kit`, choose "Up to Next Major Version" from 2.0.0, and add `LiftbridgeThemes` to the app target.

## Use LiftbridgeThemes

1. **Describe the app's own look** as a `Theme` with every color given. It's the default and is listed first.

   ```swift
   import LiftbridgeThemes

   extension Theme {
       static let house = Theme(
           id: "house", name: "My App",
           swatch: Swatch((0xF0A070, 0xB4410F), dark: (0x4A1E0C, 0xB4410F)),
           palette: Palette(
               accent: Shade(0xB4410F, 0xF08A4B),   // light, dark
               onAccent: Shade(0xFFFFFF, 0x16120F),
               canvas: Shade(0xFAF7F2, 0x16120F),
               card: Shade(0xFFFFFF, 0x241E19),
               chip: Shade(0xF1EADF, 0x2C251F),
               hairline: Shade(0xE6DED2, 0x3A322A),
               ink: Shade(0x1F1B16, 0xF6EFE6),
               muted: Shade(0x6B6259, 0xB9AFA3),
               success: Shade(0x3F6212, 0x9BC26A)))
   }

   extension ThemeStore {
       @MainActor static let app = ThemeStore(house: .house)
   }
   ```

2. **Read colors from `store.theme.palette`.** A view that reads one redraws when the theme or color mode changes, with no restart. In Black mode `store.theme` is already the black version of the chosen theme (`Theme.black`), so there's nothing extra to do for it.

   ```swift
   @MainActor
   extension Color {
       private static var palette: Palette { ThemeStore.app.theme.palette }
       static var accent: Color { palette.accent.color }
       static var onAccent: Color { palette.onAccent.color }
       static var canvas: Color { palette.canvas.color }
       // card, chip, hairline, ink, muted, success the same way
   }
   ```

   Draw full-screen backgrounds with the theme's gradient: `.background(ThemeStore.app.theme.palette.canvasGradient)` (two-tone themes fade between their colors; Black stays flat black).

   Use `onAccent` for text and icons drawn on an accent fill, including `.borderedProminent` buttons (`.foregroundStyle(Color.onAccent)`): some themes have pale accents in dark mode, where white text can't be read.

3. **Apply the accent and color mode at the root**, from a view or view modifier (not from the `App` itself), so a change redraws right away:

   ```swift
   struct Themed: ViewModifier {
       func body(content: Content) -> some View {
           content
               .tint(Color.accent)
               .preferredColorScheme(ThemeStore.app.colorMode.colorScheme)
       }
   }
   ```

4. **Add the picker to Settings:**

   ```swift
   NavigationLink("Theme") {
       ThemePicker(store: .app)
   }
   ```

   - `allSeasons: true` lists every seasonal set with its dates (handy in Debug builds).
   - `isLocked: { theme in ... }` shows a lock on themes the app doesn't offer yet and keeps them from being picked.

The choice is saved in `UserDefaults.standard` on the device. Widgets and extensions run on their own and keep the house look unless the app shares its settings with them.

## Versions

Apps depend on `from: 2.0.0`, so they take new 2.x releases when they update their packages, and never a 3.0.

- **Minor (2.1.0):** new themes, a new season, renamed themes, fixes. Safe to take any time.
- **Major (3.0.0):** a change an app has to adapt to. Listed in [CHANGELOG.md](CHANGELOG.md) with what to change.

A theme's `id` is saved on people's devices and never changes once released; its name can. A removed theme falls back to the app's own look.

New themes and seasons reach people only in an app build that includes the newer version. To pick one up, update the package in the app (Xcode: File > Packages > Update to Latest Package Versions; command line: `xcodebuild -resolvePackageDependencies` after removing the app's `Package.resolved` pin for liftbridge-kit), build, and check Settings > Theme.

## See every theme

```sh
swift run Gallery
```

Writes `gallery.html` (not committed) and opens it: every theme as a small mock screen in Light, Dark and Black mode, with its color codes, built from the same palettes apps use. Run it again after changing themes.

## Tests

```sh
swift test
```

The tests check every theme for readable contrast (WCAG AA, 4.5:1) in light, dark and Black mode, check that themes in the same group look clearly different, and cover seasons and saving the choice. CI runs them on every push.

## License

Copyright Liftbridge Labs LLC. All rights reserved. Published so Liftbridge Labs apps can use it; not licensed for other use.
