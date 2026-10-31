package com.liftbridgelabs.themes

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.LocalDate
import java.util.Locale
import kotlin.math.abs

private val roles: List<Pair<String, (Palette) -> Shade>> = listOf(
    "accent" to { p -> p.accent }, "onAccent" to { p -> p.onAccent }, "canvas" to { p -> p.canvas },
    "canvasEnd" to { p -> p.canvasEnd }, "card" to { p -> p.card }, "chip" to { p -> p.chip },
    "hairline" to { p -> p.hairline }, "ink" to { p -> p.ink }, "muted" to { p -> p.muted },
    "success" to { p -> p.success }, "chrome" to { p -> p.chrome }, "chromeEnd" to { p -> p.chromeEnd },
    "onChrome" to { p -> p.onChrome }, "selection" to { p -> p.selection }, "onSelection" to { p -> p.onSelection },
)

private fun channels(rgb: Rgb) = Integer.parseInt(rgb.hex, 16).let { listOf(it shr 16 and 0xFF, it shr 8 and 0xFF, it and 0xFF) }

/** Both platforms round computed colors to what a screen shows, so they must match exactly. */
private fun assertSame(what: String, expected: Palette, actual: Palette) {
    for ((role, pick) in roles) {
        for ((mode, dark) in listOf("light" to false, "dark" to true)) {
            val e = pick(expected)[dark]
            val a = pick(actual)[dark]
            val apart = channels(e).zip(channels(a)).maxOf { (x, y) -> abs(x - y) }
            assertTrue("$what $role $mode: Swift ${e.hex}, Kotlin ${a.hex}", apart == 0)
        }
    }
}

private val allThemes = ThemeGroup.shared.flatMap { it.themes }

private fun store(settings: MapSettings = MapSettings(), house: Theme = houseTheme) = ThemeStore(house, settings = settings)
private val houseTheme = Theme("house", "House", SwiftResults.houseSwatch, SwiftResults.house)

class MapSettings : ThemeSettings {
    val values = mutableMapOf<String, String>()
    override fun get(key: String) = values[key]
    override fun set(key: String, value: String) { values[key] = value }
}

class ParityTest {
    @Test fun catalogMatchesSwift() {
        assertEquals(SwiftResults.groups, ThemeGroup.shared.map { group -> group.id to group.themes.map { it.id } })
    }

    @Test fun blackModeMatchesSwift() {
        for (theme in allThemes) assertSame("${theme.name} black", SwiftResults.black.getValue(theme.id), theme.black.palette)
    }

    @Test fun framesMatchSwift() {
        for (theme in allThemes) assertSame("${theme.name} frame", theme.palette, theme.palette.withFrame(theme.swatch))
    }

    @Test fun anAppsOwnPaletteMatchesSwift() {
        val p = SwiftResults.house
        val given = Palette.of(p.accent, p.onAccent, p.canvas, p.card, p.chip, p.hairline, p.ink, p.muted, p.success, canvasEnd = p.canvasEnd)
        assertSame("house", SwiftResults.house, given)
        assertSame("house black", SwiftResults.houseBlack, given.black)
        assertSame("house frame", SwiftResults.houseFramed, given.withFrame(SwiftResults.houseSwatch))
    }
}

class ReadabilityTest {
    @Test fun everyThemeReadsInEveryMode() {
        for (theme in allThemes + houseTheme) {
            for ((mode, palette, dark) in listOf(Triple("light", theme.palette, false), Triple("dark", theme.palette, true),
                Triple("black", theme.black.palette, true))) {
                val p = palette
                for (background in listOf(p.canvas, p.canvasEnd, p.card, p.chip).map { it[dark] }) {
                    for (role in listOf("accent" to p.accent, "ink" to p.ink, "muted" to p.muted, "success" to p.success)) {
                        if (theme === houseTheme && mode == "light") continue // an app's own colors are its call
                        val ratio = role.second[dark].contrast(background)
                        assertTrue("${theme.name} $mode ${role.first} on ${background.hex}: $ratio", ratio >= 4.5)
                    }
                }
                for (end in listOf(p.chrome, p.chromeEnd)) {
                    assertTrue("${theme.name} $mode frame text", p.onChrome[dark].contrast(end[dark]) >= 4.5)
                    assertTrue("${theme.name} $mode selection on frame", p.selection[dark].contrast(end[dark]) >= 3)
                }
                assertTrue("${theme.name} $mode selected text", p.onSelection[dark].contrast(p.selection[dark]) >= 4.5)
            }
        }
    }

    @Test fun mathMatchesWcag() {
        assertEquals(21.0, Rgb.white.contrast(Rgb.black), 0.001)
        assertEquals(4.48, Rgb(0x777777).contrast(Rgb.white), 0.01)
        for (hex in listOf(0xB4410F, 0x2E3884, 0xF3D564, 0x777777, 0x000000, 0xFFFFFF)) {
            assertEquals(Rgb(hex).hex, Rgb.of(Rgb(hex).oklch).hex)
        }
    }
}

class StoreTest {
    private fun date(month: Int, day: Int) = LocalDate.of(2026, month, day)

    @Test fun startsWithTheHouseLookAndSystemMode() {
        val store = store()
        assertEquals("house", store.theme.id)
        assertEquals(ColorMode.SYSTEM, store.colorMode)
    }

    @Test fun remembersTheChoiceWithTheSwiftKeys() {
        val settings = MapSettings()
        store(settings).apply {
            select(allThemes.first { it.id == "fern" })
            select(ColorMode.BLACK)
        }
        assertEquals("fern", settings.values["LiftbridgeThemes.theme"])
        assertEquals("black", settings.values["LiftbridgeThemes.colorMode"])
        val again = store(settings)
        assertEquals("fern", again.theme.id)
        assertEquals(Rgb.black, again.theme.palette.canvas.dark)
    }

    @Test fun unknownSavedThemeFallsBackToHouse() {
        val settings = MapSettings().apply { values["LiftbridgeThemes.theme"] = "retired" }
        assertEquals("house", store(settings).theme.id)
    }

    @Test fun onlyTheCurrentSeasonShows() {
        val store = store()
        val october = store.visibleGroups(date(10, 29)).map { it.id }
        assertTrue("halloween" in october)
        assertFalse("thanksgiving" in october)
        assertTrue(store.visibleGroups(date(3, 1)).all { it.season == null })
        assertEquals(ThemeGroup.shared.size, store.visibleGroups(date(3, 1), allSeasons = true).size)
        assertEquals("house", store.visibleGroups(date(3, 1)).first().themes.first().id)
    }

    @Test fun aChosenSeasonalThemeStaysListed() {
        val store = store()
        store.select(ThemeGroup.shared.first { it.id == "halloween" }.themes.first())
        assertTrue("halloween" in store.visibleGroups(date(11, 15)).map { it.id })
    }

    @Test fun seasonsAndLabels() {
        val holidays = ThemeGroup.shared.first { it.id == "holidays" }.season!!
        assertTrue(holidays.contains(date(12, 24)) && holidays.contains(date(1, 5)))
        assertFalse(holidays.contains(date(1, 6)))
        assertEquals("Nov 1 – Nov 30", ThemeGroup.shared.first { it.id == "thanksgiving" }.season!!.label(Locale.US))
    }
}
