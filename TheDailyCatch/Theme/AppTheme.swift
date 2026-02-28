import SwiftUI

enum AppTheme {
    // MARK: - Light Palette (Onboarding / Splash / Completion)
    static let cream = Color(hex: "F2EDE4")
    static let warmWhite = Color(hex: "FAF8F5")
    static let lightBg = Color(hex: "F2EDE4")

    // MARK: - Dark Palette (News Feed)
    static let navy = Color(hex: "0A1628")
    static let darkNavy = Color(hex: "060F1D")
    static let cardBackground = Color(hex: "111D30")
    static let cardBorder = Color(hex: "1A2940")

    // MARK: - Accent Colors
    static let gold = Color(hex: "D4A843")           // Money – Warm Gold
    static let accentBlue = Color(hex: "5B7FBF")     // Tech – Slate Blue
    static let accentRed = Color(hex: "C7685E")      // Politics – Dusty Rose
    static let mint = Color(hex: "5BA89E")            // Climate – Sage Teal
    static let periwinkle = Color(hex: "8E8FC7")      // Culture – Muted Violet
    static let terracotta = Color(hex: "B8705A")      // Business – Terracotta
    static let softCyan = Color(hex: "4A9EB5")        // Sports – Soft Cyan
    static let mauve = Color(hex: "B07AA8")           // World – Mauve
    static let softGreen = Color(hex: "6BAF7B")       // Health – Soft Green
    static let sand = Color(hex: "C4A87A")            // Housing – Sand

    // MARK: - Text Colors
    static let textCream = Color(hex: "F2EDE4")
    static let textMidGrey = Color(hex: "8B8B97")
    static let textLightGrey = Color(hex: "C8C5BE")
    static let textDark = Color(hex: "2A2A2A")

    // MARK: - Custom Font Names
    private static let junicodeFont = "Junicode-BoldCondensed"
    private static let spaceGroteskFont = "SpaceGrotesk-Light"
    private static let disketMonoFont = "DisketMono-Bold"

    // MARK: - Typography

    /// Junicode Bold Condensed — titles, headlines like "HELP US SET UP YOUR CATCH"
    static func headline(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .custom(junicodeFont, size: size)
    }

    /// Space Grotesk — body text, subtitles
    static func body(_ size: CGFloat) -> Font {
        .custom(spaceGroteskFont, size: size)
    }

    /// Disket Mono Bold — buttons, monospaced UI elements
    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(disketMonoFont, size: size)
    }

    // MARK: - Category Colors
    static func categoryColor(from hex: String) -> Color {
        Color(hex: hex)
    }
}
