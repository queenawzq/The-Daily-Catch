import Foundation

class OpenRouterService {
    static let shared = OpenRouterService()

    private let endpoint = "https://openrouter.ai/api/v1/chat/completions"
    private let model = "perplexity/sonar"

    private var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["OpenRouterAPIKey"] as? String else {
            return ""
        }
        return key
    }

    func fetchBrief(topics: [TopicInterest], energyMode: EnergyMode, lifeStage: LifeStage?, motivation: ReadingMotivation?) async throws -> [Story] {
        let topicsList = topics.map(\.newsPrompt).joined(separator: ", ")
        let wordCount = energyMode.summaryWordCount

        let toneHint: String
        if let motivation = motivation {
            switch motivation {
            case .conversations: toneHint = "Frame stories so the reader can discuss them confidently with others."
            case .betterDecisions: toneHint = "Emphasize actionable takeaways and decision-relevant context."
            case .genuinelyCurious: toneHint = "Go deeper on the interesting details and connections."
            case .helpsAtWork: toneHint = "Focus on professional relevance and industry implications."
            case .lessAnxious: toneHint = "Be balanced and measured, avoid sensationalism, include constructive angles."
            }
        } else {
            toneHint = "Keep it balanced and accessible."
        }

        let stageHint: String
        if let stage = lifeStage {
            switch stage {
            case .stillInSchool: stageHint = "The reader is a student — use relatable examples and explain jargon."
            case .earlyCareer: stageHint = "The reader is early in their career — focus on career and financial relevance."
            case .buildingSomething: stageHint = "The reader is an entrepreneur/builder — highlight startup and business angles."
            case .settledCareer: stageHint = "The reader has an established career — focus on big-picture impact."
            case .figuringItOut: stageHint = "The reader is exploring — keep things broad and inspiring."
            }
        } else {
            stageHint = "Write for a general adult audience."
        }

        let categoryColors = [
            "3366FF", "4ECDC4", "FF6B5A", "E8B84B", "7B9BFF"
        ]

        let systemPrompt = """
        You are a sharp, clear news curator. Write with authority but keep it accessible. \
        No fluff, no clickbait. Inform the reader efficiently. \
        \(toneHint) \(stageHint)
        """

        let topicCategories = topics.map { topic -> String in
            switch topic {
            case .money: return "MONEY"
            case .techAI: return "TECH"
            case .politics: return "POLITICS"
            case .climate: return "CLIMATE"
            case .healthScience: return "HEALTH"
            case .culture: return "CULTURE"
            case .globalAffairs: return "WORLD"
            case .businessStartups: return "BUSINESS"
            case .sports: return "SPORTS"
            case .housingRealEstate: return "HOUSING"
            }
        }
        let categoriesList = topicCategories.joined(separator: ", ")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let todayString = dateFormatter.string(from: Date())

        let userPrompt = """
        Today is \(todayString). Give me the top 5 news stories from the last 24-48 hours about: \(topicsList).

        IMPORTANT: Only include stories that broke or had major developments within the last 48 hours. Do NOT include older stories. Each story MUST be directly related to one of the user's selected topics. You MUST include at least one story from EACH of the user's selected topics: \(topicsList). Distribute the 5 stories as evenly as possible across all selected topics.

        For each story, provide a JSON object with these exact fields:
        - "category": MUST be one of these categories that match the user's interests: \(categoriesList)
        - "categoryColor": a hex color for the category from this list: \(categoryColors.joined(separator: ", "))
        - "headline": clear, compelling headline (max 12 words)
        - "hook": what happened, in about \(wordCount) words — the core news
        - "context": why it matters right now, in about \(wordCount) words — the bigger picture
        - "soWhat": how this affects the reader personally, in 1-2 sentences
        - "source": name of the primary news source
        - "sourceURL": URL to the original article
        - "sources": array of source names (e.g. ["Reuters", "BBC", "NYT"])
        - "readTime": estimated read time (e.g. "2 min read")
        - "timestamp": when the story broke (e.g. "2h ago", "Today")
        - "imageURL": a direct URL to a relevant, publicly accessible news photo or image for this story (from Reuters, AP, AFP, or the source's website). Must be a real working image URL, not a placeholder.

        Return ONLY a JSON array of 5 objects. No markdown, no code fences, just the raw JSON array.
        """

        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ]
        ]

        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("The Daily Catch", forHTTPHeaderField: "X-Title")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw OpenRouterError.httpError(statusCode)
        }

        return try parseStories(from: data)
    }

    private static func imageURL(from rawURL: String?) -> String? {
        guard let url = rawURL, !url.isEmpty, url.hasPrefix("http") else { return nil }
        return url
    }

    private static let categoryColorMap: [String: String] = [
        "MONEY": "E8B84B",
        "TECH": "3366FF",
        "POLITICS": "FF6B5A",
        "CLIMATE": "4ECDC4",
        "HEALTH": "4ECDC4",
        "CULTURE": "7B9BFF",
        "WORLD": "FF6B5A",
        "BUSINESS": "E8B84B",
        "SPORTS": "3366FF",
        "HOUSING": "7B9BFF"
    ]

    private static func colorForCategory(_ category: String) -> String {
        let key = category.uppercased()
        return categoryColorMap[key] ?? "3366FF"
    }

    private func parseStories(from data: Data) throws -> [Story] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw OpenRouterError.invalidResponse
        }

        let cleaned = content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = cleaned.data(using: .utf8),
              let storyDicts = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            throw OpenRouterError.parsingFailed
        }

        return storyDicts.compactMap { dict in
            guard let headline = dict["headline"] as? String,
                  let category = dict["category"] as? String,
                  let hook = dict["hook"] as? String,
                  let context = dict["context"] as? String,
                  let soWhat = dict["soWhat"] as? String,
                  let source = dict["source"] as? String else {
                return nil
            }
            return Story(
                id: UUID(),
                headline: headline,
                category: category,
                categoryColor: Self.colorForCategory(category),
                hook: hook,
                context: context,
                soWhat: soWhat,
                source: source,
                sourceURL: dict["sourceURL"] as? String ?? "",
                sources: dict["sources"] as? [String] ?? [source],
                readTime: dict["readTime"] as? String ?? "2 min read",
                timestamp: dict["timestamp"] as? String ?? "Today",
                imageURL: Self.imageURL(from: dict["imageURL"] as? String)
            )
        }
    }
}

enum OpenRouterError: LocalizedError {
    case httpError(Int)
    case invalidResponse
    case parsingFailed

    var errorDescription: String? {
        switch self {
        case .httpError(let code): return "API error (HTTP \(code))"
        case .invalidResponse: return "Invalid response from API"
        case .parsingFailed: return "Failed to parse stories"
        }
    }
}
