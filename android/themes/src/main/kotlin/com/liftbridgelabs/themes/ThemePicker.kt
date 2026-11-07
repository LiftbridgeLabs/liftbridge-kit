package com.liftbridgelabs.themes

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.GridItemSpan
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.time.LocalDate

private val cardShape = RoundedCornerShape(12.dp)

/**
 * Color mode (Light, Dark, Black, System) and a grid of theme cards, grouped,
 * with the in-season group marked "New". Each card is filled with its theme's
 * frame, as the app will show it. Works with touch and with a TV remote: the
 * focused card grows a little and gets a ring, and select picks it.
 *
 * @param allSeasons lists every seasonal group with its dates (for testers).
 * @param isLocked marks themes the app doesn't offer yet; they show a lock and can't be picked.
 * @param columns the grid; by default cards at least 180 dp wide, growing with the font size.
 */
@Composable
fun ThemePicker(
    store: ThemeStore,
    modifier: Modifier = Modifier,
    allSeasons: Boolean = false,
    isLocked: (Theme) -> Boolean = { false },
    today: LocalDate = LocalDate.now(),
    columns: GridCells? = null,
) {
    val page = store.colors()
    val language = store.language
    // The largest font sizes (150% and up): the color modes stacked and badges
    // under their headings, so every word stays whole.
    val fontScale = LocalDensity.current.fontScale
    val large = fontScale >= LARGE_FONT_SCALE
    val dark = store.isDark()
    LazyVerticalGrid(
        // Cards widen with the text, so a phone goes to one per row before names break.
        columns = columns ?: GridCells.Adaptive(180.dp * fontScale.coerceAtLeast(1f)),
        modifier = modifier.background(page.canvasGradient),
        contentPadding = PaddingValues(16.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        item(span = { GridItemSpan(maxLineSpan) }) { Heading(localized("Color mode", language), badge = null, page, large) }
        item(span = { GridItemSpan(maxLineSpan) }) {
            val tile: @Composable (ColorMode, Modifier) -> Unit = { mode, tileModifier ->
                Tile(
                    selected = store.colorMode == mode,
                    page = page,
                    fill = Brush.verticalGradient(listOf(page.card, page.card)),
                    onClick = { store.select(mode) },
                    modifier = tileModifier,
                    description = mode.title(language),
                ) {
                    Label(mode.title(language), page.ink, Modifier.fillMaxWidth())
                }
            }
            // Four across when the longest word fits on its tile; stacked otherwise
            // (the largest font sizes, or a language with longer words).
            val measurer = rememberTextMeasurer()
            val density = LocalDensity.current
            BoxWithConstraints {
                val widest = ColorMode.entries.maxOf { measurer.measure(it.title(language), labelStyle).size.width }
                val tileWidth = with(density) { widest.toDp() } + TILE_INSET * 2
                val fits = tileWidth * ColorMode.entries.size + 10.dp * (ColorMode.entries.size - 1) <= maxWidth
                if (large || !fits) {
                    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        ColorMode.entries.forEach { tile(it, Modifier.fillMaxWidth()) }
                    }
                } else {
                    Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                        ColorMode.entries.forEach { tile(it, Modifier.weight(1f)) }
                    }
                }
            }
        }
        store.visibleGroups(today, allSeasons).forEach { group ->
            val badge = group.season?.let { season ->
                when {
                    season.contains(today) -> localized("New", language)
                    allSeasons -> season.label()
                    else -> null
                }
            }
            item(span = { GridItemSpan(maxLineSpan) }, key = "group-${group.id}") { Heading(group.title(language), badge, page, large) }
            group.themes.forEach { theme ->
                item(key = "theme-${group.id}-${theme.id}") {
                    val look = (if (store.colorMode == ColorMode.BLACK) theme.black else theme).palette.colors(dark)
                    val locked = isLocked(theme)
                    val name = theme.name(language)
                    Tile(
                        selected = store.theme.id == theme.id,
                        page = page,
                        fill = Brush.verticalGradient(listOf(look.chrome, look.chromeEnd)),
                        onClick = { store.select(theme) },
                        enabled = !locked,
                        description = if (locked) localized("%@, locked", language).replace("%@", name) else name,
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Label(name, look.onChrome, Modifier.weight(1f))
                            Spacer(Modifier.width(8.dp))
                            when {
                                locked -> Label(localized("Locked", language), look.onChrome)
                                store.theme.id == theme.id -> Label("✓", look.onChrome)
                                // The theme's accent, on its own reading color.
                                else -> Box(
                                    Modifier.size(24.dp).background(look.canvas, CircleShape),
                                    contentAlignment = Alignment.Center,
                                ) { Box(Modifier.size(14.dp).background(look.accent, CircleShape)) }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun Heading(title: String, badge: String?, page: ThemeColors, large: Boolean) {
    val heading = @Composable {
        BasicText(title, style = TextStyle(color = page.ink, fontSize = 18.sp, fontWeight = FontWeight.SemiBold))
    }
    val pill = @Composable {
        if (badge != null) {
            BasicText(
                badge,
                Modifier.background(page.chip, RoundedCornerShape(50)).padding(horizontal = 8.dp, vertical = 2.dp),
                style = TextStyle(color = page.ink, fontSize = 12.sp, fontWeight = FontWeight.SemiBold),
            )
        }
    }
    // At the largest font sizes the badge ("New", a season's dates) sits under the heading.
    if (large) {
        Column(Modifier.padding(top = 8.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) { heading(); pill() }
    } else {
        Row(Modifier.padding(top = 8.dp), verticalAlignment = Alignment.CenterVertically) {
            heading()
            if (badge != null) Spacer(Modifier.width(8.dp))
            pill()
        }
    }
}

private val labelStyle = TextStyle(fontSize = 15.sp, fontWeight = FontWeight.SemiBold)

/** A tile's space around its content on each side: the ring margin plus the inner padding. */
private val TILE_INSET = 16.dp

/** Android's font scale from which the picker switches to its large layout (150%). */
private const val LARGE_FONT_SCALE = 1.5f

@Composable
private fun Label(text: String, color: Color, modifier: Modifier = Modifier) {
    // No line limit: at large font sizes a name wraps rather than being cut off.
    BasicText(text, modifier, style = labelStyle.copy(color = color))
}

/** A picker card: grows and gets a ring in the page's text color when focused; a ring when selected. */
@Composable
private fun Tile(
    selected: Boolean,
    page: ThemeColors,
    fill: Brush,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    description: String,
    content: @Composable () -> Unit,
) {
    var focused by remember { mutableStateOf(false) }
    // The ring sits in a fixed 4 dp margin, so focusing a card never moves the grid.
    val ring = if (focused) 3.dp else 2.dp
    Box(
        modifier
            .scale(if (focused) 1.05f else 1f)
            .heightIn(min = 60.dp)
            .border(ring, if (focused || selected) page.ink else Color.Transparent, cardShape)
            .padding(TILE_INSET - 12.dp)
            .background(fill, cardShape)
            .onFocusChanged { focused = it.isFocused }
            .clickable(enabled = enabled, role = Role.Button, onClick = onClick)
            .semantics {
                contentDescription = description
                this.selected = selected
            }
            .padding(12.dp),
        contentAlignment = Alignment.CenterStart,
    ) { content() }
}
