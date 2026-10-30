import SwiftUI

// iPhone, iPad and Mac. A TV app builds its own picker for the remote from
// ThemeStore (visibleGroups, select, colorMode) and Swatch.gradient.
#if !os(tvOS)

/// Color mode (Light, Dark, Black, System) and a grid of theme cards, grouped,
/// with the in-season group marked "New". Push it from Settings.
public struct ThemePicker: View {
    @Bindable private var store: ThemeStore
    private let allSeasons: Bool
    private let isLocked: (Theme) -> Bool
    @Environment(\.colorScheme) private var colorScheme

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
                section("Color mode") {
                    HStack(spacing: 8) {
                        ForEach(ColorMode.allCases) { mode in modeButton(mode) }
                    }
                }
                ForEach(store.visibleGroups(on: now, allSeasons: allSeasons)) { group in
                    section(group.title, badge: badge(for: group, on: now)) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
                            ForEach(group.themes) { theme in card(theme) }
                        }
                    }
                }
            }
            .padding()
        }
        .background(background)
        .navigationTitle("Theme")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private func badge(for group: ThemeGroup, on date: Date) -> String? {
        guard let season = group.season else { return nil }
        return season.contains(date) ? "New" : allSeasons ? season.label() : nil
    }

    private func section<Content: View>(_ title: String, badge: String? = nil,
                                        @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
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

    private func modeButton(_ mode: ColorMode) -> some View {
        let selected = store.colorMode == mode
        return Button { store.colorMode = mode } label: {
            // Icon over the word, so four fit across a phone.
            VStack(spacing: 4) {
                Image(systemName: mode.systemImage).imageScale(.medium)
                Text(mode.title).lineLimit(1).minimumScaleFactor(0.8)
            }
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
        return Button { store.select(theme) } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(theme.swatch.gradient(for: colorScheme))
                    .overlay(Circle().strokeBorder(.primary.opacity(0.12)))
                    .frame(width: 36, height: 36)
                Text(theme.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.ink.color)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if locked {
                    Image(systemName: "lock.fill").imageScale(.small).foregroundStyle(palette.muted.color)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(cardFill, in: shape)
            .overlay(outline(selected))
        }
        .buttonStyle(.plain)
        .disabled(locked)
        .accessibilityLabel(locked ? "\(theme.name), locked" : theme.name)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var shape: RoundedRectangle { RoundedRectangle(cornerRadius: 12, style: .continuous) }

    private func outline(_ selected: Bool) -> some View {
        shape.strokeBorder(selected ? AnyShapeStyle(.tint) : AnyShapeStyle(palette.hairline.color), lineWidth: selected ? 2.5 : 1)
    }

    // Drawn in the theme's own colors, so Black mode is pure black here too.
    private var palette: Palette { store.theme.palette }
    private var background: Color { palette.canvas.color }
    private var cardFill: Color { palette.card.color }
}

#endif
