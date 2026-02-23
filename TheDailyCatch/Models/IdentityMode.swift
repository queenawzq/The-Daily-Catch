import Foundation

enum IdentityMode: String, Codable, CaseIterable, Identifiable {
    case founder
    case creative
    case investing
    case globalCitizen
    case selfGrowth

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .founder: return "Founder"
        case .creative: return "Creative"
        case .investing: return "Investing"
        case .globalCitizen: return "Global Citizen"
        case .selfGrowth: return "Self Growth"
        }
    }

    var emoji: String {
        switch self {
        case .founder: return "🚀"
        case .creative: return "🎨"
        case .investing: return "📈"
        case .globalCitizen: return "🌍"
        case .selfGrowth: return "🧠"
        }
    }

    var newsPrompt: String {
        switch self {
        case .founder: return "startup funding, tech industry, entrepreneurship, product launches, venture capital"
        case .creative: return "design trends, creative technology, entertainment industry, art and culture, creator economy"
        case .investing: return "stock market, cryptocurrency, personal finance, economic policy, investment strategies"
        case .globalCitizen: return "world politics, climate change, human rights, international relations, social impact"
        case .selfGrowth: return "mental health, productivity, wellness trends, career development, psychology research"
        }
    }
}
