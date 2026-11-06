package com.liftbridgelabs.themes

import java.util.Locale

// The picker's text in the app's language. The text comes from the Swift kit
// (GeneratedStrings.kt), keyed by the English; text the kit has no entry for
// (an app's own theme name) shows as given.

/** The languages the kit's text comes in. */
val kitLanguages: Set<String> = setOf("en") + translations.keys

internal fun localized(text: String, language: String): String = translations[language]?.get(text) ?: text

/** The name in one of the kit's languages ("de"). `name` stays the English one. */
fun Theme.name(language: String): String = localized(name, language)

/** The heading in one of the kit's languages ("de"). `title` stays the English one. */
fun ThemeGroup.title(language: String): String = localized(title, language)

/** The mode's name in one of the kit's languages ("de"). */
fun ColorMode.title(language: String): String = localized(title, language)

/**
 * The language to show: the phone's (or the app's own language setting), if
 * both the app and the kit have it, else English. Android can't tell which
 * languages an app has, so the app lists them (`ThemeStore(languages = ...)`);
 * that keeps an English-only app from showing a German picker.
 */
internal fun pickLanguage(appLanguages: Set<String>, locale: Locale = Locale.getDefault()): String =
    locale.language.takeIf { it in appLanguages && it in kitLanguages } ?: "en"
