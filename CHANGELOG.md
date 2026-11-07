# Changelog

## 2.6.1 (Nov 7, 2026)

- **Whole words at every text size.** At the largest text sizes the picker broke words mid-word and cut off the color modes. Now, on Apple and Android:
  - Theme cards widen as the text grows, so a phone goes from two cards per row to one before a name has to break (tablets keep more per row).
  - The color modes sit four across only when every word fits; otherwise (the largest sizes, or a language with longer words, such as German on Android) they stack, one full-width row each.
  - At the largest sizes a group's badge ("New", a season's dates) sits under its heading instead of beside it.
  - Text is never capped: it grows with the person's setting.
- Checked in an app and a sample on iPhone and Android, in English and German, from the default size up to the largest.

## 2.6.0 (Nov 6, 2026)

- **German on Android.** The Android picker shows the same German text as Apple's: color modes, "New", "Locked", group headings and every theme name. The text is generated from the Swift kit's language files (`swift run KotlinCatalog` writes `GeneratedStrings.kt`), so the two can't drift. Android can't tell which languages an app has, so an app with German lists them: `ThemeStore(..., languages = setOf("en", "de"))`; the default, English only, keeps the picker English. For a custom picker: `theme.name(store.language)`, `group.title(store.language)`, `mode.title(store.language)`.
- The gallery shows each theme's German name under its English one.

## 2.5.0 (Nov 6, 2026)

- **German.** The picker's title, color modes, "New" badge, group headings and all 51 theme names in German. The picker follows the app's language, not the phone's, so an English-only app stays English. For a custom picker: `Theme.localizedName`, `ThemeGroup.localizedTitle`, and `ColorMode.title` (now localized). `name` and `title` stay English. A test checks every name and heading has German. Apple only so far; Android stays English.

## 2.4.0 (Oct 30, 2026)

- **Android.** `LiftbridgeThemes` for Android (Kotlin, Jetpack Compose, API 26+, phones and TV) in `android/`: the same catalog, theme ids and colors, Light / Dark / Black / System saved on the device under the same keys, a Compose palette (`LiftbridgeTheme`, `LocalThemeColors`), `FrameFade`, and a `ThemePicker` that works with a TV remote as well as touch. Its colors are generated from the Swift catalog (`swift run KotlinCatalog`), and its tests check that its color math gives exactly the same colors as Swift's. Apps include it from source (`includeBuild`), see the README.
- **Computed colors are rounded to what a screen shows** (whole steps of 1/255), so contrast is tested on the displayed colors and both platforms get identical values. The change is under 1/255 per channel.
- CI builds and tests the Android library and fails if its colors fall behind the Swift catalog.

## 2.3.0 (Oct 30, 2026)

- **`FrameFade`**: the frame's color fading to clear (36 pt by default), to put right under a header band so it eases into the content instead of ending in a hard line. Also as a gradient: `palette.frameFade`. The README now describes the frame as flat `chrome` plus `FrameFade`.
- **`chromeEnd` is a slightly deeper shade of `chrome`,** never the swatch's second color, which read as a stripe of another color under a short band (gold over red in some themes). It's for a tab bar or a tall frame such as a sidebar (`chromeGradient`). A test checks that every frame's end keeps its color.

## 2.2.0 (Oct 30, 2026)

- **A strong frame color for every theme.** `Palette.chrome` and `chromeEnd` (with `chromeGradient` in SwiftUI) are the theme's bold color for the app's frame: the header above lists, tab bars and toolbars, the way a sidebar carries the theme in a desktop chat app. Light mode uses the theme's bright pair, dark mode its deep pair, Black mode pure black. `onChrome` is the text and icon color on it (white or dark), tested at 4.5:1 on both ends.
- **A selected state.** `selection` and `onSelection` mark a selected tab or row on the frame: the accent where it stands out from the frame (3:1), otherwise a pill in the frame's text color. Text on it is tested at 4.5:1.
- Content stays calm: `canvas`, `card` and `chip` are unchanged.
- **Rich tones**, a new group of 8 themes with hand-picked mid-tone backgrounds (cream, slate, deep teal) instead of near-white and near-black: Solstice, Campfire, Nightshade, Woodland, Rosewood, Fjord, Parchment, Slate.
- **The picker's cards show each theme's frame**, with its accent on its reading color, so themes look as different in the picker as in the app.
- An app's own palette without `chrome` keeps a calm frame (its canvas, with its main text color). Pass `chrome:`, `chromeEnd:` and `onChrome:` to `Palette(...)`, or call `palette.withFrame(from: swatch)` to get one from the swatch's colors.

## 2.1.1 (Oct 30, 2026)

- `canvasGradient` now runs top to bottom (it was diagonal), so a bar pinned at the top of a screen and drawn in `canvas` matches the background above the fade.

## 2.1.0 (Oct 30, 2026)

- **Gradient backgrounds.** Each palette has `canvasEnd`, where the screen's background gradient ends, and `canvasGradient` (SwiftUI), which fades `canvas` to `canvasEnd`. Two-tone themes fade between their two colors; one-color themes fade to a deeper version of their color; Black mode stays flat black. Text, accent and "done" colors are tested for contrast on both ends.
- To use it, draw full-screen backgrounds with `.background(palette.canvasGradient)` instead of `palette.canvas.color`. Apps that don't change anything keep a flat background.
- An app's own palette can pass `canvasEnd:` to `Palette(...)`; leaving it out keeps the background flat.
- The theme picker and the gallery (`swift run Gallery`) show the gradients.

## 2.0.1 (Oct 29, 2026)

- **Black is blacker.** Cards, chips and borders in Black mode are neutral #090909, #131313 and #222222 (no theme tint), on the #000000 canvas.
- **The picker draws in the theme's own colors** (canvas, card, border and text colors) instead of the system's gray backgrounds, so Black is pure black in the picker too, and a light theme tints it.

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
