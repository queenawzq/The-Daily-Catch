import SwiftUI

enum AppTheme {
    static let background = Color(hex: "0f0f1a")
    static let cardBackground = Color(hex: "1a1a2e")
    static let accent = Color(hex: "667eea")
    static let accentSecondary = Color(hex: "764ba2")
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)

    static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "0f0f1a"), Color(hex: "16213e")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let accentGradient = LinearGradient(
        colors: [accent, accentSecondary],
        startPoint: .leading,
        endPoint: .trailing
    )
}
