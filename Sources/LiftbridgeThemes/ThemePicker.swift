import SwiftUI

// iPhone, iPad and Mac. A TV app builds its own picker for the remote from
// ThemeStore (visibleGroups, select, colorMode), Swatch.gradient and the
// localized names (Theme.localizedName, ThemeGroup.localizedTitle, ColorMode.title).
#if !os(tvOS)

/// Color mode (Light, Dark, Black, System) and a grid of theme cards, grouped,
/// with the in-season group marked "New". Push it from Settings.
public struct ThemePicker: View {
    @Bindable private var store: ThemeStore
    @Environment(\.dynamicTypeSize) private var typeSize
    /// A card's narrowest width, growing with the text so names wrap at whole words.
    @ScaledMetric(relativeTo: .subheadline) private var cardWidth: CGFloat = 165
    private let allSeasons: Bool
    private let isLocked: (Theme) -> Bool

    /// `allSeasons` lists every seasonal group (for testers); `isLocked`
    /// shows a lock on themes the app doesn't offer yet.
    public init(store: ThemeStore, allSeasons: Bool = false, isLocked: @escaping (Theme) -> Bool = { _ in false }) {
        self.store = store
        self.allSeasons = allSeasons
        self.isLocked = isLocked
    }

    public var body: some View {
        // The date at drawing time is enough: the picker isn't open across midnight.
        let now = Date.now
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                section(Localized.string("Color mode")) {
                    // Four across when every word fits; stacked, one per row, at the
                    // largest text sizes or when a language's words run longer.
                    if large {
                        modes(stacked: true)
                    } else {
                        ViewThatFits(in: .horizontal) {
                            modes(stacked: false)
                            modes(stacked: true)
                        }
                    }
                }
                ForEach(store.visibleGroups(on: now, allSeasons: allSeasons)) { group in
                    section(group.localizedTitle, badge: badge(for: group, on: now)) {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(group.themes) { theme in card(theme) }
                        }
                    }
                }
            }
            .padding()
        }
        .background(background)
        .navigationTitle(Localized.string("Theme"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    /// The accessibility text sizes (the largest five).
    private var large: Bool { typeSize.isAccessibilitySize }

    /// As many cards across as fit at `cardWidth`: two on a phone at most sizes,
    /// one at the larger ones, more on a wider screen.
    private var columns: [GridItem] { [GridItem(.adaptive(minimum: cardWidth), spacing: 10)] }

    private func badge(for group: ThemeGroup, on date: Date) -> String? {
        guard let season = group.season else { return nil }
        return season.contains(date) ? Localized.string("New") : allSeasons ? season.label() : nil
    }

    private func section<Content: View>(_ title: String, badge: String? = nil,
                                        @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // At the largest text sizes the badge ("New", a season's dates) sits under the heading.
            (large ? AnyLayout(VStackLayout(alignment: .leading, spacing: 6)) : AnyLayout(HStackLayout(spacing: 8))) {
                Text(title).font(.headline).foregroundStyle(palette.ink.color)
                if let badge {
                    Text(badge)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .foregroundStyle(.tint)
                        .background(.tint.opacity(0.15), in: Capsule())
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            content()
        }
    }

    private func modes(stacked: Bool) -> some View {
        (stacked ? AnyLayout(VStackLayout(spacing: 8)) : AnyLayout(HStackLayout(spacing: 8))) {
            ForEach(ColorMode.allCases) { mode in modeButton(mode, stacked: stacked) }
        }
    }

    private func modeButton(_ mode: ColorMode, stacked: Bool) -> some View {
        let selected = store.colorMode == mode
        return Button { store.colorMode = mode } label: {
            // Icon over the word, so four fit across a phone; side by side in a
            // full-width row when stacked.
            (stacked ? AnyLayout(HStackLayout(spacing: 10)) : AnyLayout(VStackLayout(spacing: 4))) {
                Image(systemName: mode.systemImage).imageScale(.medium)
                // Whole words: across, a word that doesn't fit makes the modes stack;
                // stacked, a title may still wrap on a very narrow screen.
                Text(mode.title).fixedSize(horizontal: !stacked, vertical: true)
                if stacked { Spacer(minLength: 0) }
            }
            .padding(.horizontal, stacked ? 14 : 6)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(palette.ink.color)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(cardFill, in: shape)
            .overlay(outline(selected))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func card(_ theme: Theme) -> some View {
        let selected = store.theme.id == theme.id
        let locked = isLocked(theme)
        // The card is the theme's frame, as the app will show it in this mode.
        let look = (store.colorMode == .black ? theme.black : theme).palette
        return Button { store.select(theme) } label: {
            HStack(spacing: 10) {
                Text(theme.localizedName)
                    .font(.subheadline.weight(.semibold))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if locked {
                    Image(systemName: "lock.fill").imageScale(.small)
                } else if selected {
                    Image(systemName: "checkmark.circle.fill").imageScale(.large)
                } else {
                    // The theme's accent, on its own reading surface.
                    Circle().fill(look.accent.color)
                        .frame(width: 14, height: 14)
                        .padding(5)
                        .background(look.canvas.color, in: Circle())
                }
            }
            .foregroundStyle(look.onChrome.color)
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(look.chromeGradient, in: shape)
            .overlay(outline(selected))
        }
        .buttonStyle(.plain)
        .disabled(locked)
        .accessibilityLabel(locked ? String(format: Localized.string("%@, locked"), theme.localizedName) : theme.localizedName)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var shape: RoundedRectangle { RoundedRectangle(cornerRadius: 12, style: .continuous) }

    private func outline(_ selected: Bool) -> some View {
        shape.inset(by: selected ? -4 : 0)
            .strokeBorder(selected ? AnyShapeStyle(palette.ink.color) : AnyShapeStyle(palette.hairline.color),
                          lineWidth: selected ? 2.5 : 1)
    }

    // Drawn in the theme's own colors, so Black mode is pure black here too.
    private var palette: Palette { store.theme.palette }
    private var background: LinearGradient { palette.canvasGradient }
    private var cardFill: Color { palette.card.color }
}

#endif
