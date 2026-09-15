import AppKit
import SwiftUI
import TableMacroCore

/// TableMacro's visual identity: one saturated signature accent, plus a
/// distinct vivid color per desk zone so a result reads at a glance instead
/// of through a single monochrome highlight.
enum TableMacroTheme {
    static let background = Color(nsColor: .windowBackgroundColor)

    /// The app's signature accent — a saturated violet rather than system blue.
    static let accent = Color(red: 0.42, green: 0.24, blue: 0.98)

    /// One vivid, distinct color per desk zone, used throughout the desk map
    /// and anywhere a result needs to read at a glance.
    static func color(for zone: DeskZone) -> Color {
        switch zone {
        case .leftTop: return Color(red: 1.00, green: 0.34, blue: 0.20)     // ember
        case .leftBottom: return Color(red: 1.00, green: 0.64, blue: 0.05) // amber
        case .rightTop: return Color(red: 0.04, green: 0.78, blue: 0.62)  // jade
        case .rightBottom: return Color(red: 0.20, green: 0.55, blue: 1.00) // azure
        }
    }
}

extension View {
    @ViewBuilder
    func tablemacroPrimaryButton() -> some View {
        if #available(macOS 26.0, *) {
            self.buttonStyle(.glassProminent).tint(TableMacroTheme.accent)
        } else {
            self.buttonStyle(.borderedProminent).tint(TableMacroTheme.accent)
        }
    }

    @ViewBuilder
    func tablemacroSecondaryButton() -> some View {
        self.buttonStyle(.bordered).tint(TableMacroTheme.accent)
    }

    /// A bold, softly gradiented panel used in place of plain system
    /// materials, tinted by whichever color is contextually relevant.
    func tablemacroCard(tint: Color = TableMacroTheme.accent) -> some View {
        self
            .background(
                LinearGradient(
                    colors: [tint.opacity(0.18), tint.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(tint.opacity(0.35), lineWidth: 1.5)
            )
    }
}

extension Font {
    /// A heavy, rounded display face for screen titles — replaces the
    /// original's quiet system-weight headings with something louder.
    static func tablemacroTitle(_ size: CGFloat = 30) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
}
