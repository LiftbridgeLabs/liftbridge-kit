package com.liftbridgelabs.themes

import java.util.Locale
import kotlin.math.atan2
import kotlin.math.cbrt
import kotlin.math.cos
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sin

/**
 * An sRGB color, 0..1 per channel, with the math themes need: WCAG contrast
 * and OKLCH (lightness, chroma, hue), where changing lightness keeps a color
 * looking like the same color. The same math as the Swift kit's RGB.swift.
 */
data class Rgb(val red: Double, val green: Double, val blue: Double) {
    constructor(hex: Int) : this(
        ((hex shr 16) and 0xFF) / 255.0,
        ((hex shr 8) and 0xFF) / 255.0,
        (hex and 0xFF) / 255.0,
    )

    /** "B4410F" */
    val hex: String get() = String.format(Locale.ROOT, "%02X%02X%02X", byte(red), byte(green), byte(blue))

    /** The color as opaque 0xAARRGGBB, as Android's color ints are. */
    val argb: Int get() = (0xFF shl 24) or (byte(red) shl 16) or (byte(green) shl 8) or byte(blue)

    /** The color as a screen shows it: each channel a whole step of 1/255. */
    val displayed: Rgb get() = Rgb(byte(red) / 255.0, byte(green) / 255.0, byte(blue) / 255.0)

    /** WCAG relative luminance. */
    val luminance: Double get() = 0.2126 * linear(red) + 0.7152 * linear(green) + 0.0722 * linear(blue)

    /** WCAG contrast ratio, 1..21. Body text needs 4.5. */
    fun contrast(other: Rgb): Double {
        val (a, b) = luminance to other.luminance
        return (max(a, b) + 0.05) / (min(a, b) + 0.05)
    }

    val oklch: Oklch
        get() {
            // Björn Ottosson's OKLab, https://bottosson.github.io/posts/oklab/
            val r = linear(red)
            val g = linear(green)
            val b = linear(blue)
            val l = cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b)
            val m = cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b)
            val s = cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b)
            val bigL = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
            val bigA = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s
            val bigB = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
            return Oklch(bigL, hypot(bigA, bigB), atan2(bigB, bigA))
        }

    companion object {
        val white = Rgb(0xFFFFFF)
        val black = Rgb(0x000000)

        /**
         * The color, with chroma lowered until it fits in sRGB (so the hue
         * holds), rounded to what a screen shows (whole steps of 1/255), as
         * the Swift kit does.
         */
        fun of(lch: Oklch): Rgb {
            val lightness = lch.lightness.coerceIn(0.0, 1.0)
            var chroma = max(lch.chroma, 0.0)
            while (chroma > 0) {
                exact(Oklch(lightness, chroma, lch.hue))?.let { return it.displayed }
                chroma -= 0.002
            }
            return (exact(Oklch(lightness, 0.0, 0.0)) ?: black).displayed
        }

        private fun exact(lch: Oklch): Rgb? {
            val a = lch.chroma * cos(lch.hue)
            val b = lch.chroma * sin(lch.hue)
            val bigL = lch.lightness
            val l = (bigL + 0.3963377774 * a + 0.2158037573 * b).pow(3)
            val m = (bigL - 0.1055613458 * a - 0.0638541728 * b).pow(3)
            val s = (bigL - 0.0894841775 * a - 1.2914855480 * b).pow(3)
            val r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
            val g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
            val bl = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
            val tolerance = 0.0005
            if (listOf(r, g, bl).any { it < -tolerance || it > 1 + tolerance }) return null
            return Rgb(gamma(r.coerceIn(0.0, 1.0)), gamma(g.coerceIn(0.0, 1.0)), gamma(bl.coerceIn(0.0, 1.0)))
        }

        // Half away from zero, as Swift's rounded(); every value here is >= 0.
        private fun byte(value: Double): Int = Math.round(value.coerceIn(0.0, 1.0) * 255).toInt()
        private fun linear(c: Double): Double = if (c <= 0.04045) c / 12.92 else ((c + 0.055) / 1.055).pow(2.4)
        private fun gamma(c: Double): Double = if (c <= 0.0031308) c * 12.92 else 1.055 * c.pow(1 / 2.4) - 0.055
    }
}

/** OKLCH: lightness 0..1, chroma (0 is gray, ~0.37 the most vivid), hue in radians. */
data class Oklch(val lightness: Double, val chroma: Double, val hue: Double)
