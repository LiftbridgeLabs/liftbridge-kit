package com.liftbridgelabs.themes

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.util.Locale

class LanguageTest {
    private val german = Locale.GERMANY

    @Test fun everyNameHeadingAndLabelHasGerman() {
        val texts = listOf("Color mode", "New", "%@, locked", "Locked") + ColorMode.entries.map { it.title } +
            ThemeGroup.shared.flatMap { listOf(it.title) + it.themes.map { theme -> theme.name } }
        val missing = texts.filter { it !in translations.getValue("de") }
        assertTrue("No German for $missing", missing.isEmpty())
    }

    @Test fun germanNamesStayDistinct() {
        val names = ThemeGroup.shared.flatMap { it.themes }.map { it.name("de") }
        assertEquals(names.size, names.toSet().size)
        assertEquals("Süßes oder Saures", ThemeGroup.shared.flatMap { it.themes }.first { it.id == "trick-or-treat" }.name("de"))
        assertEquals("Dunkel", ColorMode.DARK.title("de"))
    }

    @Test fun anAppsOwnNameShowsAsGiven() {
        assertEquals("House", Theme("house", "House", SwiftResults.houseSwatch, SwiftResults.house).name("de"))
    }

    @Test fun followsTheAppsLanguagesNotJustThePhones() {
        // An English-only app stays English on a German phone.
        assertEquals("en", pickLanguage(setOf("en"), german))
        assertEquals("de", pickLanguage(setOf("en", "de"), german))
        // A language the kit doesn't have yet falls back to English.
        assertEquals("en", pickLanguage(setOf("en", "fr"), Locale.FRANCE))
        assertEquals("en", pickLanguage(setOf("en", "de"), Locale.US))
    }
}
