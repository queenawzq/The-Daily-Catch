import SwiftUI

struct TimelineEvent: Codable {
    let date: String
    let description: String
}

struct SourceCoverage: Codable, Identifiable {
    var id: String { name + angle }
    let name: String
    let angle: String
    let stance: String
    let headline: String?
    let summary: String?
    let date: String?
    let sourceURL: String?

    enum CodingKeys: String, CodingKey {
        case name, angle, stance, headline, summary, date, sourceURL
    }
}

struct LinkedTerm: Codable {
    let term: String
    let explanation: String
}

struct KeyStat: Codable {
    let number: String
    let context: String
}

struct Story: Codable, Identifiable {
    let id: UUID
    let headline: String
    let category: String
    let categoryColor: String
    let hook: String
    let context: String
    let soWhat: String
    let deepDive: String
    let keyStat: KeyStat?
    let keyFacts: [String]?
    let source: String
    let sourceURL: String
    let sources: [String]
    let readTime: String
    let timestamp: String
    let imageURL: String?
    let timeline: [TimelineEvent]?
    let fullCoverage: [SourceCoverage]?
    let whatToWatch: String?
    let linkedTerms: [LinkedTerm]?
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
