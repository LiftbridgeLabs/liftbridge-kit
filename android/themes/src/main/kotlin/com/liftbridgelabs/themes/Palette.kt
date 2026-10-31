package com.liftbridgelabs.themes

import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale

/** One color in its light-mode and dark-mode versions. */
data class Shade(val light: Rgb, val dark: Rgb) {
    constructor(light: Int, dark: Int) : this(Rgb(light), Rgb(dark))

    internal fun with(dark: Boolean, value: Rgb) = if (dark) copy(dark = value) else copy(light = value)
    internal operator fun get(dark: Boolean) = if (dark) this.dark else light
}

/**
 * The colors an app draws with; every theme fills in all of them. The same
 * roles as the Swift kit's Palette.
 */
data class Palette(
    /** Buttons, links, highlights. */
    val accent: Shade,
    /** Text and icons drawn on an accent fill. */
    val onAccent: Shade,
    /** The screen behind everything; the top of its gradient. */
    val canvas: Shade,
    /** Where the screen's gradient ends (the bottom); the same as `canvas` for a flat background. */
    val canvasEnd: Shade,
    /** Cards and rows on the canvas. */
    val card: Shade,
    /** Small filled shapes: tags, chips. */
    val chip: Shade,
    /** Thin borders and dividers. */
    val hairline: Shade,
    /** Main text. */
    val ink: Shade,
    /** Secondary text. */
    val muted: Shade,
    /** Checked off, finished, saved. */
    val success: Shade,
    /** The app's frame (header above lists, tab bar, toolbars). Draw it flat, with `FrameFade` below a header band. */
    val chrome: Shade,
    /** A slightly deeper shade of `chrome`, for a tab bar or a tall frame. */
    val chromeEnd: Shade,
    /** Text and icons on the frame. */
    val onChrome: Shade,
    /** A selected tab or row on the frame. */
    val selection: Shade,
    /** Text and icons on `selection`. */
    val onSelection: Shade,
) {
    /**
     * The palette with a strong frame in the swatch's color: the bright swatch
     * in light mode, the deep one in dark mode. The frame's text is white or
     * the palette's dark text (black if that can't read), and the frame moves
     * away from it where needed to reach 4.5:1.
     */
    fun withFrame(swatch: Swatch): Palette {
        var palette = this
        for ((dark, stops) in listOf(false to swatch.light, true to swatch.dark)) {
            val top = stops.firstOrNull() ?: continue
            // The far end is a slightly deeper shade of the same color, never
            // the swatch's second color (a stripe in a short band).
            val deeper = top.oklch
            val bottom = Rgb.of(deeper.copy(lightness = deeper.lightness - 0.06))
            val whiteScore = minOf(Rgb.white.contrast(top), Rgb.white.contrast(bottom))
            val inkScore = minOf(ink.light.contrast(top), ink.light.contrast(bottom))
            var text = if (whiteScore >= inkScore) Rgb.white else ink.light
            var frame = framed(top, bottom, text)
            if (text != Rgb.white && frame.any { text.contrast(it) < READABLE }) {
                text = Rgb.black
                frame = framed(top, bottom, text)
            }
            palette = palette.copy(
                chrome = palette.chrome.with(dark, frame[0]),
                chromeEnd = palette.chromeEnd.with(dark, frame[1]),
                onChrome = palette.onChrome.with(dark, text),
            )
        }
        return palette.withSelection()
    }

    /**
     * Dark mode on true black: canvas and frame #000000, cards, chips and
     * borders #090909, #131313, #222222. Text, accent and success colors move
     * only where one wouldn't read on the darker surfaces.
     */
    val black: Palette
        get() {
            var p = copy(
                canvas = canvas.copy(dark = Rgb.black),
                canvasEnd = canvasEnd.copy(dark = Rgb.black),
                card = card.copy(dark = Rgb(0x090909)),
                chip = chip.copy(dark = Rgb(0x131313)),
                hairline = hairline.copy(dark = Rgb(0x222222)),
            )
            val backgrounds = listOf(p.canvas.dark, p.card.dark, p.chip.dark)
            p = p.copy(
                ink = p.ink.copy(dark = tuned(p.ink.dark, backgrounds, 0.005)),
                muted = p.muted.copy(dark = tuned(p.muted.dark, backgrounds, 0.005)),
                success = p.success.copy(dark = tuned(p.success.dark, backgrounds, 0.005)),
                accent = p.accent.copy(dark = tuned(p.accent.dark, backgrounds, 0.005)),
            )
            if (p.accent.dark != accent.dark) {
                // A lightened accent reads on pure black, so black text always
                // works on it; white or the app's dark text first if they do.
                val fill = p.accent.dark
                val text = listOf(Rgb.white, p.ink.light, Rgb.black).firstOrNull { it.contrast(fill) >= READABLE } ?: Rgb.black
                p = p.copy(onAccent = p.onAccent.copy(dark = text))
            }
            p = p.copy(
                chrome = p.chrome.copy(dark = Rgb.black),
                chromeEnd = p.chromeEnd.copy(dark = Rgb.black),
                onChrome = p.onChrome.copy(dark = p.ink.dark),
            )
            return p.withSelection()
        }

    /**
     * The accent marks a selected item where it stands out from the frame
     * (3:1); otherwise a pill in the frame's text color, with the frame's
     * color as its text.
     */
    internal fun withSelection(): Palette {
        var p = this
        for (dark in listOf(false, true)) {
            val frame = listOf(chrome[dark], chromeEnd[dark])
            val fill = accent[dark]
            p = if (frame.all { fill.contrast(it) >= 3 }) {
                p.copy(selection = p.selection.with(dark, fill), onSelection = p.onSelection.with(dark, onAccent[dark]))
            } else {
                val pill = onChrome[dark]
                p.copy(selection = p.selection.with(dark, pill), onSelection = p.onSelection.with(dark, frame.maxBy { pill.contrast(it) }))
            }
        }
        return p
    }

    companion object {
        /** WCAG AA for body text. */
        const val READABLE = 4.5

        /**
         * An app's own palette. Without `chrome` the frame is the canvas with
         * the main text color on it (calm); `withFrame` gives it a theme's
         * strong color. Selection is worked out from the rest.
         */
        fun of(
            accent: Shade, onAccent: Shade, canvas: Shade, card: Shade, chip: Shade, hairline: Shade,
            ink: Shade, muted: Shade, success: Shade, canvasEnd: Shade? = null,
            chrome: Shade? = null, chromeEnd: Shade? = null, onChrome: Shade? = null,
        ): Palette = Palette(
            accent = accent, onAccent = onAccent, canvas = canvas, canvasEnd = canvasEnd ?: canvas,
            card = card, chip = chip, hairline = hairline, ink = ink, muted = muted, success = success,
            chrome = chrome ?: canvas, chromeEnd = chromeEnd ?: chrome ?: canvasEnd ?: canvas,
            onChrome = onChrome ?: ink, selection = accent, onSelection = onAccent,
        ).withSelection()

        /** The color moved along lightness only (same hue) until it reads on every background. */
        internal fun tuned(color: Rgb, backgrounds: List<Rgb>, step: Double, floor: Double = 0.0): Rgb {
            var lch = color.oklch
            lch = lch.copy(lightness = maxOf(lch.lightness, floor))
            var rgb = Rgb.of(lch)
            while (backgrounds.any { rgb.contrast(it) < READABLE } && lch.lightness in 0.0..1.0) {
                lch = lch.copy(lightness = lch.lightness + step)
                rgb = Rgb.of(lch)
            }
            return rgb
        }

        private fun framed(top: Rgb, bottom: Rgb, text: Rgb): List<Rgb> {
            val step = if (text == Rgb.white) -0.005 else 0.005
            return listOf(tuned(top, listOf(text), step), tuned(bottom, listOf(text), step))
        }
    }
}

/** The two-color swatch for a theme: a bright pair for light mode and a deep pair for dark mode. */
data class Swatch(val light: List<Rgb>, val dark: List<Rgb>) {
    companion object {
        /** A swatch from 0xRRGGBB pairs; the dark pair defaults to the light one. */
        fun of(light: Pair<Int, Int>, dark: Pair<Int, Int> = light) =
            Swatch(listOf(Rgb(light.first), Rgb(light.second)), listOf(Rgb(dark.first), Rgb(dark.second)))
    }
}

/** A named theme. Its `id` is saved on devices: never change one that has shipped. */
data class Theme(val id: String, val name: String, val swatch: Swatch, val palette: Palette) {
    /** The theme for Black mode (see `Palette.black`); worked out once. */
    val black: Theme by lazy { copy(palette = palette.black) }
}

/** When a seasonal group shows: from one month and day to another, every year (Gregorian). */
data class Season(val startMonth: Int, val startDay: Int, val endMonth: Int, val endDay: Int) {
    fun contains(date: LocalDate): Boolean {
        val today = date.monthValue * 100 + date.dayOfMonth
        val from = startMonth * 100 + startDay
        val through = endMonth * 100 + endDay
        // A season can run past New Year (Dec 1 through Jan 5).
        return if (from <= through) today in from..through else today >= from || today <= through
    }

    /** "Nov 1 – Nov 30" */
    fun label(locale: Locale = Locale.getDefault()): String {
        val format = DateTimeFormatter.ofPattern("MMM d", locale)
        val start = LocalDate.of(2001, startMonth, startDay).format(format)
        val end = LocalDate.of(2001, endMonth, endDay).format(format)
        return "$start – $end"
    }
}

/** A heading in the picker and its themes. Seasonal groups show only in season, marked "New". */
data class ThemeGroup(val id: String, val title: String, val themes: List<Theme>, val season: Season? = null) {
    companion object {
        /** Every shared group, in picker order, the same as the Swift kit's `ThemeGroup.shared`. */
        val shared: List<ThemeGroup> get() = GeneratedCatalog.groups
    }
}
