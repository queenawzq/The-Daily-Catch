import Foundation

enum LifeStage: String, Codable, CaseIterable, Identifiable {
    case stillInSchool
    case earlyCareer
    case buildingSomething
    case settledCareer
    case figuringItOut

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .stillInSchool: return "Still in school"
        case .earlyCareer: return "Early career"
        case .buildingSomething: return "Building something"
        case .settledCareer: return "Settled career"
        case .figuringItOut: return "Figuring it out"
        }
    }

    var emoji: String {
        switch self {
        case .stillInSchool: return "📚"
        case .earlyCareer: return "💼"
        case .buildingSomething: return "🚀"
        case .settledCareer: return "🏠"
        case .figuringItOut: return "🧭"
        }
    }
}

enum TopicInterest: String, Codable, CaseIterable, Identifiable {
    case money
    case techAI
    case politics
    case climate
    case healthScience
    case culture
    case globalAffairs
    case businessStartups
    case sports
    case housingRealEstate

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .money: return "Money"
        case .techAI: return "Tech & AI"
        case .politics: return "Politics"
        case .climate: return "Climate"
        case .healthScience: return "Health & Science"
        case .culture: return "Culture"
        case .globalAffairs: return "Global Affairs"
        case .businessStartups: return "Business & Startups"
        case .sports: return "Sports"
        case .housingRealEstate: return "Real Estate"
        }
    }

    var emoji: String {
        switch self {
        case .money: return "💰"
        case .techAI: return "🤖"
        case .politics: return "🏛️"
        case .climate: return "🌍"
        case .healthScience: return "🧬"
        case .culture: return "🎭"
        case .globalAffairs: return "🌐"
        case .businessStartups: return "📈"
        case .sports: return "⚽"
        case .housingRealEstate: return "🏡"
        }
    }

    var newsPrompt: String {
        switch self {
        case .money: return "personal finance, investing, cryptocurrency, economic policy"
        case .techAI: return "artificial intelligence, tech industry, software, gadgets"
        case .politics: return "politics, policy, elections, government"
        case .climate: return "climate change, sustainability, environment, energy"
        case .healthScience: return "health, medical research, science, wellness"
        case .culture: return "entertainment, arts, media, pop culture, social trends"
        case .globalAffairs: return "international relations, world politics, geopolitics"
        case .businessStartups: return "startups, venture capital, entrepreneurship, business strategy"
        case .sports: return "sports, athletics, major leagues, tournaments"
        case .housingRealEstate: return "housing market, real estate, mortgages, urban development"
        }
    }
}

enum ReadingMotivation: String, Codable, CaseIterable, Identifiable {
    case conversations
    case betterDecisions
    case genuinelyCurious
    case helpsAtWork
    case lessAnxious

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .conversations: return "Have better conversations"
        case .betterDecisions: return "Make better decisions"
        case .genuinelyCurious: return "I'm genuinely curious"
        case .helpsAtWork: return "It helps at work"
        case .lessAnxious: return "To make sense of things"
        }
    }

    var emoji: String {
        switch self {
        case .conversations: return "💬"
        case .betterDecisions: return "🎯"
        case .genuinelyCurious: return "🔍"
        case .helpsAtWork: return "💼"
        case .lessAnxious: return "🧩"
        }
    }
}

enum CatchTime: String, Codable, CaseIterable, Identifiable {
    case morning
    case commute
    case lunch
    case evening

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .commute: return "Commute"
        case .lunch: return "Lunch break"
        case .evening: return "Evening"
        }
    }

    var emoji: String {
        switch self {
        case .morning: return "☀️"
        case .commute: return "🚇"
        case .lunch: return "🥗"
        case .evening: return "🌙"
        }
    }
}
