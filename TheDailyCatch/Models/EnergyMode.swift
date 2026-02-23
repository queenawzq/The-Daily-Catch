import Foundation

enum EnergyMode: String, Codable, CaseIterable, Identifiable {
    case quick
    case deep

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .quick: return "Quick"
        case .deep: return "Deep"
        }
    }

    var emoji: String {
        switch self {
        case .quick: return "⚡"
        case .deep: return "🌊"
        }
    }

    var summaryWordCount: Int {
        switch self {
        case .quick: return 30
        case .deep: return 100
        }
    }
}
