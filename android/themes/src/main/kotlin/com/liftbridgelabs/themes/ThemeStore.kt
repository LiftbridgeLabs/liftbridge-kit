package com.liftbridgelabs.themes

import android.content.Context
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import java.time.LocalDate

/** Light, Dark, Black (dark with true-black backgrounds, for OLED screens) or System. */
enum class ColorMode(val raw: String, val title: String) {
    LIGHT("light", "Light"),
    DARK("dark", "Dark"),
    BLACK("black", "Black"),
    SYSTEM("system", "System");

    companion object {
        fun from(raw: String?): ColorMode? = entries.firstOrNull { it.raw == raw }
    }
}

/** Where the choice is saved. `SharedPreferencesSettings` on a device; anything in tests. */
interface ThemeSettings {
    fun get(key: String): String?
    fun set(key: String, value: String)
}

/** The choice in the app's own preferences file, as the Swift kit keeps it in UserDefaults. */
class SharedPreferencesSettings(context: Context, name: String = "liftbridge_themes") : ThemeSettings {
    private val preferences = context.applicationContext.getSharedPreferences(name, Context.MODE_PRIVATE)
    override fun get(key: String): String? = preferences.getString(key, null)
    override fun set(key: String, value: String) = preferences.edit().putString(key, value).apply()
}

/**
 * The chosen theme and color mode, saved on the device. Screens that read
 * `theme` or `colorMode` recompose when either changes.
 *
 * @param house the app's own look, listed first and used until the person picks another.
 */
class ThemeStore(
    val house: Theme,
    val groups: List<ThemeGroup> = ThemeGroup.shared,
    private val settings: ThemeSettings,
) {
    private var chosen by mutableStateOf(
        groups.flatMap { it.themes }.firstOrNull { it.id == settings.get(THEME_KEY) } ?: house,
    )

    var colorMode: ColorMode by mutableStateOf(ColorMode.from(settings.get(COLOR_MODE_KEY)) ?: ColorMode.SYSTEM)
        private set

    /** The chosen theme, as it should be drawn: in Black mode, its black version. */
    val theme: Theme get() = if (colorMode == ColorMode.BLACK) chosen.black else chosen

    fun select(theme: Theme) {
        chosen = theme
        settings.set(THEME_KEY, theme.id)
    }

    fun select(mode: ColorMode) {
        colorMode = mode
        settings.set(COLOR_MODE_KEY, mode.raw)
    }

    /**
     * The groups to list on `date`: seasonal groups only in season (or while
     * their theme is the chosen one, so it never disappears) unless
     * `allSeasons` shows them all, and the app's look first in the first
     * year-round group.
     */
    fun visibleGroups(date: LocalDate = LocalDate.now(), allSeasons: Boolean = false): List<ThemeGroup> {
        val visible = groups.filter { group ->
            val season = group.season
            season == null || allSeasons || season.contains(date) || group.themes.any { it.id == chosen.id }
        }.toMutableList()
        val index = visible.indexOfFirst { it.season == null }
        if (index >= 0) {
            val group = visible[index]
            visible[index] = group.copy(themes = listOf(house) + group.themes)
        } else {
            visible.add(ThemeGroup(id = house.id, title = house.name, themes = listOf(house)))
        }
        return visible
    }

    companion object {
        // The same keys as the Swift kit, so the choice reads the same way on both.
        const val THEME_KEY = "LiftbridgeThemes.theme"
        const val COLOR_MODE_KEY = "LiftbridgeThemes.colorMode"
    }
}
