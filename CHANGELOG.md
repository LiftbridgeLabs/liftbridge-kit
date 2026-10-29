# Changelog

## 1.1.0 (Oct 29, 2026)

- **Black color mode** (`ColorMode.black`, saved as "black"): dark mode with true-black backgrounds for OLED screens, with any theme. The picker's mode row is now Light / Dark / Black / System. `ThemeStore.theme` returns the black version of the chosen theme while Black is on (`Theme.black`): canvas #000000, cards #0A0A0A, chips #141414, borders #262626; text and accent colors unchanged and tested for contrast on black.
- **tvOS 18.** Everything builds for Apple TV except `ThemePicker` (iPhone, iPad and Mac only). `Swatch.gradient(for:)` is now public for an app's own picker.
- An app that switches over every `ColorMode` case needs a `.black` case; apps that only use `colorMode.colorScheme` need no change.

## 1.0.0 (Oct 29, 2026)

First release.

- `LiftbridgeThemes`: Light / Dark / System color mode, the theme picker, and 46 themes.
  - Seasonal: Halloween (Oct 1 – Oct 31), Thanksgiving (Nov 1 – Nov 30), Holidays (Dec 1 – Jan 5).
  - Solid colors, Two-tone, Timeless, Color vision (red-green friendly, blue-yellow friendly).
