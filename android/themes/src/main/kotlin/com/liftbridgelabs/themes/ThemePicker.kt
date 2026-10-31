package com.liftbridgelabs.themes

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
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
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
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
 */
@Composable
fun ThemePicker(
    store: ThemeStore,
    modifier: Modifier = Modifier,
    allSeasons: Boolean = false,
    isLocked: (Theme) -> Boolean = { false },
    today: LocalDate = LocalDate.now(),
    columns: GridCells = GridCells.Adaptive(180.dp),
) {
    val page = store.colors()
    val dark = store.isDark()
    LazyVerticalGrid(
        columns = columns,
        modifier = modifier.background(page.canvasGradient),
        contentPadding = PaddingValues(16.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        item(span = { GridItemSpan(maxLineSpan) }) { Heading("Color mode", badge = null, page) }
        item(span = { GridItemSpan(maxLineSpan) }) {
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                ColorMode.entries.forEach { mode ->
                    Tile(
                        selected = store.colorMode == mode,
                        page = page,
                        fill = Brush.verticalGradient(listOf(page.card, page.card)),
                        onClick = { store.select(mode) },
                        modifier = Modifier.weight(1f),
                        description = mode.title,
                    ) {
                        Label(mode.title, page.ink, Modifier.fillMaxWidth())
                    }
                }
            }
        }
        store.visibleGroups(today, allSeasons).forEach { group ->
            val badge = group.season?.let { season ->
                when {
                    season.contains(today) -> "New"
                    allSeasons -> season.label()
                    else -> null
                }
            }
            item(span = { GridItemSpan(maxLineSpan) }, key = "group-${group.id}") { Heading(group.title, badge, page) }
            group.themes.forEach { theme ->
                item(key = "theme-${group.id}-${theme.id}") {
                    val look = (if (store.colorMode == ColorMode.BLACK) theme.black else theme).palette.colors(dark)
                    val locked = isLocked(theme)
                    Tile(
                        selected = store.theme.id == theme.id,
                        page = page,
                        fill = Brush.verticalGradient(listOf(look.chrome, look.chromeEnd)),
                        onClick = { store.select(theme) },
                        enabled = !locked,
                        description = if (locked) "${theme.name}, locked" else theme.name,
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Label(theme.name, look.onChrome, Modifier.weight(1f))
                            Spacer(Modifier.width(8.dp))
                            when {
                                locked -> Label("Locked", look.onChrome)
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
private fun Heading(title: String, badge: String?, page: ThemeColors) {
    Row(Modifier.padding(top = 8.dp), verticalAlignment = Alignment.CenterVertically) {
        BasicText(title, style = TextStyle(color = page.ink, fontSize = 18.sp, fontWeight = FontWeight.SemiBold))
        if (badge != null) {
            Spacer(Modifier.width(8.dp))
            BasicText(
                badge,
                Modifier.background(page.chip, RoundedCornerShape(50)).padding(horizontal = 8.dp, vertical = 2.dp),
                style = TextStyle(color = page.ink, fontSize = 12.sp, fontWeight = FontWeight.SemiBold),
            )
        }
    }
}

@Composable
private fun Label(text: String, color: Color, modifier: Modifier = Modifier) {
    BasicText(text, modifier, style = TextStyle(color = color, fontSize = 15.sp, fontWeight = FontWeight.SemiBold), maxLines = 2)
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
            .padding(4.dp)
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
