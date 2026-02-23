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

    func fetchBrief(identityModes: [IdentityMode], energyMode: EnergyMode) async throws -> [Story] {
        let topics = identityModes.map(\.newsPrompt).joined(separator: ", ")
        let wordCount = energyMode.summaryWordCount

        let systemPrompt = """
        You are a witty, casual news curator for Gen-Z readers. Think Morning Brew meets TikTok energy. \
        Keep it real, use conversational language, and make complex topics feel accessible. \
        Never be boring. Always be informative.
        """

        let userPrompt = """
        Give me today's top 5 news stories about: \(topics).

        For each story, provide a JSON object with these exact fields:
        - "headline": catchy, concise headline (max 10 words)
        - "summary": engaging summary in about \(wordCount) words, casual tone
        - "whyItMatters": one sentence explaining why a young person should care, start with a hook
        - "source": name of the original news source
        - "sourceURL": URL to the original article
        - "emoji": single emoji that represents the story

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

    private func parseStories(from data: Data) throws -> [Story] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw OpenRouterError.invalidResponse
        }

        // Extract JSON array from response content (may have markdown fences)
        let cleaned = content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = cleaned.data(using: .utf8),
              let storyDicts = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            throw OpenRouterError.parsingFailed
        }

        return storyDicts.enumerated().compactMap { index, dict in
            guard let headline = dict["headline"] as? String,
                  let summary = dict["summary"] as? String,
                  let whyItMatters = dict["whyItMatters"] as? String,
                  let source = dict["source"] as? String,
                  let emoji = dict["emoji"] as? String else {
                return nil
            }
            return Story(
                id: UUID(),
                headline: headline,
                summary: summary,
                whyItMatters: whyItMatters,
                source: source,
                sourceURL: dict["sourceURL"] as? String ?? "",
                emoji: emoji,
                gradientIndex: index
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
