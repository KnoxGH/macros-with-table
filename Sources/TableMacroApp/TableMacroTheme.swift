import AppKit
import SwiftUI

enum TableMacroTheme {
    static let background = Color(nsColor: .windowBackgroundColor)
}

extension View {
    @ViewBuilder
    func tablemacroPrimaryButton() -> some View {
        if #available(macOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }

    @ViewBuilder
    func tablemacroSecondaryButton() -> some View {
        self.buttonStyle(.bordered)
    }
}
