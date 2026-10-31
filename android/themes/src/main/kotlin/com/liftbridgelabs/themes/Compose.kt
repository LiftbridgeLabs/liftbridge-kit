package com.liftbridgelabs.themes

import androidx.compose.foundation.background
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/** A palette's colors for one mode, ready for Compose. */
@Immutable
data class ThemeColors(
    val isDark: Boolean,
    val accent: Color,
    val onAccent: Color,
    val canvas: Color,
    val canvasEnd: Color,
    val card: Color,
    val chip: Color,
    val hairline: Color,
    val ink: Color,
    val muted: Color,
    val success: Color,
    val chrome: Color,
    val chromeEnd: Color,
    val onChrome: Color,
    val selection: Color,
    val onSelection: Color,
) {
    /** The screen's background, `canvas` at the top to `canvasEnd` at the bottom. */
    val canvasGradient: Brush get() = Brush.verticalGradient(listOf(canvas, canvasEnd))

    /** `chrome` deepening to `chromeEnd`: for a tall frame such as a sidebar. A header band is flat `chrome`. */
    val chromeGradient: Brush get() = Brush.verticalGradient(listOf(chrome, chromeEnd))

    /** `chrome` fading to clear, under a header band (see `FrameFade`). */
    val frameFade: Brush get() = Brush.verticalGradient(listOf(chrome, chrome.copy(alpha = 0f)))
}

fun Rgb.toColor(): Color = Color(red.toFloat(), green.toFloat(), blue.toFloat())

/** The palette's colors in light or dark mode. */
fun Palette.colors(dark: Boolean): ThemeColors = ThemeColors(
    isDark = dark,
    accent = accent[dark].toColor(),
    onAccent = onAccent[dark].toColor(),
    canvas = canvas[dark].toColor(),
    canvasEnd = canvasEnd[dark].toColor(),
    card = card[dark].toColor(),
    chip = chip[dark].toColor(),
    hairline = hairline[dark].toColor(),
    ink = ink[dark].toColor(),
    muted = muted[dark].toColor(),
    success = success[dark].toColor(),
    chrome = chrome[dark].toColor(),
    chromeEnd = chromeEnd[dark].toColor(),
    onChrome = onChrome[dark].toColor(),
    selection = selection[dark].toColor(),
    onSelection = onSelection[dark].toColor(),
)

/** Whether the store's color mode draws dark: Dark and Black do, System follows the device. */
@Composable
fun ThemeStore.isDark(): Boolean = when (colorMode) {
    ColorMode.LIGHT -> false
    ColorMode.DARK, ColorMode.BLACK -> true
    ColorMode.SYSTEM -> isSystemInDarkTheme()
}

/** The chosen theme's colors for the current mode. */
@Composable
fun ThemeStore.colors(): ThemeColors = theme.palette.colors(isDark())

/** The colors of the theme around this screen; set by `LiftbridgeTheme`. */
val LocalThemeColors = staticCompositionLocalOf<ThemeColors> {
    error("No theme colors: wrap the app's content in LiftbridgeTheme(store) { ... }")
}

/**
 * Gives everything inside the chosen theme's colors (`LocalThemeColors`).
 * Changing the theme or mode in the store recomposes it.
 */
@Composable
fun LiftbridgeTheme(store: ThemeStore, content: @Composable () -> Unit) {
    CompositionLocalProvider(LocalThemeColors provides store.colors(), content = content)
}

/**
 * The soft bottom edge of a header band: the frame's color fading to clear
 * over the content. Draw it right under the band, overlapping the content
 * (for example in a Box over the list, aligned to the top), so it doesn't
 * push the content down.
 */
@Composable
fun FrameFade(modifier: Modifier = Modifier, height: Dp = 36.dp, colors: ThemeColors = LocalThemeColors.current) {
    Box(modifier.fillMaxWidth().height(height).background(colors.frameFade))
}
