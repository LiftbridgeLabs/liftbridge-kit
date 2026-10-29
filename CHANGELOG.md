# Changelog

## 2.0.0 (Oct 29, 2026)

**To update:** change the package requirement to `from: 2.0.0`. If the app switches over every `ColorMode` case, add `.black`; apps that only use `colorMode.colorScheme` need no other change.

- **Themes look clearly different.** Backgrounds now carry each theme's color in light and dark mode (canvas and chips clearly tinted, cards lightly), instead of only the accent changing. Maple is now red with a gold background, Jam Session has a grape-purple accent, and Snowfall has an icy-blue background. A test checks that themes in the same group look different.
- **Black color mode** (`ColorMode.black`, saved as "black"): dark mode with a true-black canvas for OLED screens, with any theme. The picker's mode row is Light / Dark / Black / System. While Black is on, `ThemeStore.theme` returns the chosen theme's black version (`Theme.black`): canvas #000000; cards, chips and borders at the lightness of #0A0A0A, #141414 and #262626 with a hint of the theme's color. Text, accent and "done" colors stay the same unless one wouldn't read on black, including in an app's own palette.
- **tvOS 18.** Everything builds for Apple TV except `ThemePicker` (iPhone, iPad and Mac only). `Swatch.gradient(for:)` is now public for an app's own picker.
- **Each group lists its most distinct themes first,** so an app that shows only the first few (for example 5 per group) still offers clearly different choices.
- Fixed colors (color-vision accents and "done" colors, an app's own success color) are adjusted where they wouldn't read on the stronger backgrounds.

## 1.0.0 (Oct 29, 2026)

First release.

- `LiftbridgeThemes`: Light / Dark / System color mode, the theme picker, and 46 themes.
  - Seasonal: Halloween (Oct 1 – Oct 31), Thanksgiving (Nov 1 – Nov 30), Holidays (Dec 1 – Jan 5).
  - Solid colors, Two-tone, Timeless, Color vision (red-green friendly, blue-yellow friendly).
