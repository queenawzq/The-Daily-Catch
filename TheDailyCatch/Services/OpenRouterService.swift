import Foundation

class OpenRouterService {
    static let shared = OpenRouterService()

    private let serverBaseURL = "https://the-daily-catch-server-production.up.railway.app"

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

        let systemPrompt = """
        You are a news curator who prioritizes understanding over volume. Your guiding question for every story: "Why would a busy person care about this?" Work backward from that to what happened.

        SELECTION HIERARCHY — apply in order:
        1. Dinner Table Test (mandatory): "Is this something people are actually talking about or would want to discuss?" If a story dominates the news cycle, it MUST appear. An informed person who reads your briefing should never think "how did they miss that?"
        2. Scale of Impact: Does this change how people live, work, spend, or plan?
        3. Context Gap: Is this something people saw a headline about but couldn't explain?

        EDITORIAL RULES:
        - Never editorialize on who is right or wrong.
        - No loaded adjectives ("controversial," "shocking," "unprecedented").
        - Do not frame stories as two-sided conflicts when they are more nuanced.
        - Let facts and context do the work.
        - When uncertain, say so: "it's unclear whether," "analysts are divided on."
        - Political stories must read as neutral to readers across the spectrum. A conservative and a liberal should both feel the summary is fair.

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
        let allCategories = "MONEY, TECH, POLITICS, CLIMATE, HEALTH, CULTURE, WORLD, BUSINESS, SPORTS, HOUSING"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let todayString = dateFormatter.string(from: Date())

        // Slot distribution: Lead(T1), T2, T3, T1-second, Wildcard
        var slotCategories: [String] = []
        switch topicCategories.count {
        case 0:
            slotCategories = ["WORLD", "TECH", "POLITICS", "HEALTH", "BUSINESS"]
        case 1:
            slotCategories = [topicCategories[0], topicCategories[0], topicCategories[0],
                              topicCategories[0], topicCategories[0]]
        case 2:
            // Lead(T1), T2, T1-second, T2-second, Wildcard
            slotCategories = [topicCategories[0], topicCategories[1],
                              topicCategories[0], topicCategories[1], "WILDCARD"]
        default:
            // Lead(T1), T2, T3, T1-second, Wildcard
            slotCategories = [topicCategories[0], topicCategories[1],
                              topicCategories[2], topicCategories[0], "WILDCARD"]
        }

        // Build descriptive slot assignment text for the prompt
        var slotLines: [String] = []
        for (i, cat) in slotCategories.enumerated() {
            let num = i + 1
            if i == 0 {
                slotLines.append("- Story #\(num) — LEAD STORY (category = \"\(cat)\"): The single biggest, most talked-about headline within this category. If someone read only this story, they'd still feel plugged into the news. Apply the Dinner Table Test at maximum strength here.")
            } else if cat == "WILDCARD" {
                slotLines.append("- Story #\(num) — WILDCARD (category = any of: \(categoriesList)): The story the reader didn't know they needed. Surprising, important, and conversation-worthy. Pick the most compelling unused story from any of the user's topics.")
            } else if i == 3 && topicCategories.count >= 3 {
                slotLines.append("- Story #\(num) (category = \"\(cat)\"): Second-best story from the user's primary interest. Must be genuinely compelling on its own, not filler.")
            } else {
                slotLines.append("- Story #\(num) (category = \"\(cat)\"): The most important story from this category.")
            }
        }
        let slotAssignmentText = slotLines.joined(separator: "\n        ")

        let userPrompt = """
        Today is \(todayString). Give me the 5 most important stories a person should know about right now.

        SLOT ASSIGNMENTS:
        \(slotAssignmentText)

        CATEGORY FIT TEST:
        "Would this story appear in a dedicated [CATEGORY] section of a major newspaper?" If no, pick a different story.
        - TECH = technology companies, products, AI, software, hardware, chips, apps, cybersecurity.
        - BUSINESS = companies, earnings, markets, startups, M&A, retail, labor.
        - MONEY = personal finance, investing, interest rates, crypto, economic indicators.
        - WORLD = international relations, geopolitics, foreign affairs, conflicts.
        - POLITICS = domestic policy, elections, legislation, government actions.
        - HEALTH = medical research, public health, FDA, wellness.
        - CLIMATE = environment, energy, sustainability, extreme weather.
        - CULTURE = entertainment, arts, media, social trends, viral moments.
        - SPORTS = athletic competitions, teams, players, tournaments, records.
        - HOUSING = real estate, mortgages, urban development, housing data.

        ROOT CAUSE RULE:
        When a story's root cause is a war, conflict, or political action, it belongs in WORLD or POLITICS — even if its effects touch other sectors. "Oil prices surge because of war" = WORLD. "Airlines cancel flights because of conflict" = WORLD. The root cause determines the category.
        Exception: if a secondary effect has become its own standalone story with independent developments (e.g., OPEC announces a production increase in response), that can be categorized independently.

        STORY DISTINCTNESS:
        Each story must teach the reader something they would not learn from the other four. Apply this test: if you removed this story, would the reader still learn about the same event from another story? If yes, you have a duplicate — replace it.
        Two stories CAN involve the same broader situation IF they cover genuinely independent developments with different stakeholders, data, and implications.

        VIOLENCE / CRIME RULE:
        Stories about shootings, attacks, hate crimes, terrorism, or violent incidents belong in POLITICS or WORLD only — never TECH, SPORTS, CULTURE, HEALTH, CLIMATE, MONEY, BUSINESS, or HOUSING, even if they happen at a school, stadium, concert, hospital, or business.

        RECENCY CHECK:
        Only include stories that broke or had a major NEW development within the last 24 hours. Before including any story, ask: "Did something new happen with this in the last 24 hours, or am I recycling an older story?" If you are not confident it's fresh, do not include it.

        SO-WHAT GATEKEEPER:
        If you cannot write a compelling "soWhat" explaining how this story affects the reader's life, money, career, or understanding of the world — the story does not belong. Replace it with one where the stakes are clear.

        SOURCES:
        Each story must be cross-referenced across at least 2-3 sources. Prefer wire services (Reuters, AP) as the factual backbone. The "sources" array must list the actual outlets you consulted, not generic names.

        CATEGORY VALUES — use EXACTLY these strings, no variations:
        \(allCategories)

        For each story, return a JSON object with these exact fields:
        - "category": one of the exact category strings above
        - "headline": clear, compelling headline (max 12 words)
        - "hook": One sentence, plain language. What happened. ~\(wordCount) words.
        - "context": 2-3 sentences. Why now, what led here, the bigger picture. ~\(wordCount) words.
        - "soWhat": 1-2 sentences. How this affects the reader. The most important field.
        - "keyStat": {"number": "90%", "context": "explanation"} — most striking stat. Omit if none.
        - "keyFacts": array of 5-7 concise facts beyond the hook/context. Plain text, no bullet markers.
        - "deepDive": 3-4 sentences combining key facts into prose with historical context and competing perspectives.
        - "source": primary news source name
        - "sourceURL": URL to the original article
        - "sources": array of exactly 3 real outlet names
        - "readTime": e.g. "2 min read"
        - "timestamp": when the story broke, e.g. "2h ago", "Today"

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

        var allStories = try parseStories(from: data)

        // Slot-aware category validation
        for i in 0..<allStories.count {
            if i < slotCategories.count {
                let expectedCat = slotCategories[i]

                if Self.isViolenceOrConflictStory(allStories[i]) && expectedCat != "WORLD" && expectedCat != "POLITICS" {
                    allStories[i] = Self.storyWithCategory(allStories[i], category: "WORLD")
                } else if expectedCat == "WILDCARD" {
                    // Wildcard slot: validate category but let AI choose
                    let normalized = allStories[i].category.uppercased()
                    let validCat = Self.validCategories.contains(normalized) ? normalized : "WORLD"
                    allStories[i] = Self.storyWithCategory(allStories[i], category: validCat)
                } else {
                    allStories[i] = Self.storyWithCategory(allStories[i], category: expectedCat)
                }
            } else {
                let normalized = allStories[i].category.uppercased()
                let validCat = Self.validCategories.contains(normalized) ? normalized : "WORLD"
                if validCat != allStories[i].category {
                    allStories[i] = Self.storyWithCategory(allStories[i], category: validCat)
                }
            }
        }

        return allStories
    }

    private static func imageURL(from rawURL: String?) -> String? {
        guard let url = rawURL, !url.isEmpty, url.hasPrefix("http") else { return nil }
        return url
    }

    private static let categoryColorMap: [String: String] = [
        "MONEY": "D4A843",
        "TECH": "5B7FBF",
        "POLITICS": "C7685E",
        "CLIMATE": "5BA89E",
        "HEALTH": "6BAF7B",
        "CULTURE": "8E8FC7",
        "WORLD": "B07AA8",
        "BUSINESS": "B8705A",
        "SPORTS": "4A9EB5",
        "HOUSING": "C4A87A"
    ]

    /// Returns a copy of the story with a new category and color.
    private static func storyWithCategory(_ story: Story, category: String) -> Story {
        Story(
            id: story.id, headline: story.headline,
            category: category, categoryColor: colorForCategory(category),
            hook: story.hook, context: story.context,
            soWhat: story.soWhat, deepDive: story.deepDive,
            keyStat: story.keyStat, keyFacts: story.keyFacts,
            source: story.source, sourceURL: story.sourceURL,
            sources: story.sources, readTime: story.readTime,
            timestamp: story.timestamp, imageURL: story.imageURL,
            timeline: story.timeline, fullCoverage: story.fullCoverage,
            whatToWatch: story.whatToWatch, linkedTerms: story.linkedTerms
        )
    }

    private static let validCategories: Set<String> = [
        "MONEY", "TECH", "POLITICS", "CLIMATE", "HEALTH",
        "CULTURE", "WORLD", "BUSINESS", "SPORTS", "HOUSING"
    ]

    /// Strong conflict, violence, and crime signals — stories matching these should NOT be
    /// forced into soft categories (TECH, SPORTS, CULTURE, etc.). Label them WORLD or POLITICS.
    private static let violenceSignals: [String] = [
        // War / military
        "missile", "airstrike", "troops", "invasion", "war with",
        "iran", "israel", "gaza", "ukraine", "hamas", "hezbollah",
        // Shootings / domestic violence
        "shooter", "shooting", "gunman", "gunfire", "mass shooting",
        // Attacks / terrorism / hate crimes
        "truck attack", "attack on", "bombing", "stabbing", "terrorist",
        "hate crime", "antisemit", "synagogue", "mosque attack", "church attack"
    ]

    /// Checks whether story content is clearly about violence, conflict, or crime.
    private static func isViolenceOrConflictStory(_ story: Story) -> Bool {
        let text = " \(story.headline) \(story.hook) \(story.context) ".lowercased()
        return violenceSignals.contains { text.contains($0) }
    }

    private static func colorForCategory(_ category: String) -> String {
        let key = category.uppercased()
        return categoryColorMap[key] ?? "3366FF"
    }

    // MARK: - Server-backed fetch (fast, pre-generated)

    private struct ServerBriefResponse: Codable {
        let generatedAt: String
        let stories: [ServerStory]
    }

    private struct ServerStory: Codable {
        let id: String
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

    private struct ServerDeepContent: Codable {
        let timeline: [TimelineEvent]?
        let fullCoverage: [SourceCoverage]?
        let whatToWatch: String?
        let linkedTerms: [LinkedTerm]?
    }

    /// Fetch brief from The Daily Catch server (pre-generated, fast).
    func fetchBriefFromServer(topics: [TopicInterest], energyMode: EnergyMode) async throws -> [Story] {
        let topicParams = topics.map(\.rawValue).joined(separator: ",")
        guard let url = URL(string: "\(serverBaseURL)/api/brief?topics=\(topicParams)&energy=\(energyMode.rawValue)") else {
            throw OpenRouterError.invalidResponse
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw OpenRouterError.httpError(statusCode)
        }

        let decoder = JSONDecoder()
        let briefResponse = try decoder.decode(ServerBriefResponse.self, from: data)

        return briefResponse.stories.map { s in
            Story(
                id: UUID(uuidString: s.id) ?? UUID(),
                headline: s.headline,
                category: s.category,
                categoryColor: s.categoryColor,
                hook: s.hook,
                context: s.context,
                soWhat: s.soWhat,
                deepDive: s.deepDive,
                keyStat: s.keyStat,
                keyFacts: s.keyFacts,
                source: s.source,
                sourceURL: s.sourceURL,
                sources: s.sources,
                readTime: s.readTime,
                timestamp: s.timestamp,
                imageURL: s.imageURL,
                timeline: s.timeline,
                fullCoverage: s.fullCoverage,
                whatToWatch: s.whatToWatch,
                linkedTerms: s.linkedTerms
            )
        }
    }

    /// Fetch deep content from The Daily Catch server (pre-generated, fast).
    func fetchDeepContentFromServer(storyId: String) async throws -> DeepContent {
        guard let url = URL(string: "\(serverBaseURL)/api/deep/\(storyId)") else {
            throw OpenRouterError.invalidResponse
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw OpenRouterError.httpError(statusCode)
        }

        let decoder = JSONDecoder()
        let serverDeep = try decoder.decode(ServerDeepContent.self, from: data)
        return DeepContent(
            timeline: serverDeep.timeline,
            fullCoverage: serverDeep.fullCoverage,
            whatToWatch: serverDeep.whatToWatch,
            linkedTerms: serverDeep.linkedTerms
        )
    }

    // MARK: - Deep Content (lazy-loaded per story)

    struct DeepContent {
        let timeline: [TimelineEvent]?
        let fullCoverage: [SourceCoverage]?
        let whatToWatch: String?
        let linkedTerms: [LinkedTerm]?
    }

    func fetchDeepContent(headline: String, hook: String, context: String, sources: [String]) async throws -> DeepContent {
        let systemPrompt = """
        You are a news analyst providing deep-dive content for a specific story. Your job is to make the reader feel like they just had a 10-minute conversation with a knowledgeable friend who follows this topic closely.

        Be factual, balanced, and thorough. Prioritize:
        - Context that makes the reader smarter, not just more informed
        - Connections to things the reader already knows about
        - Explaining WHY something matters, not just WHAT happened
        - Plain language over jargon. When jargon is unavoidable, explain it.
        """

        let sourcesHint = sources.joined(separator: ", ")

        let userPrompt = """
        Given this news story:

        Headline: \(headline)
        Summary: \(hook)
        Context: \(context)
        Sources consulted: \(sourcesHint)

        Provide deep-dive supplementary content as a single JSON object with these fields:

        - "timeline": array of 3-5 objects with {"date": "Mar 2024", "description": "What happened"} — chronological events leading to this story. Focus on the moments that explain WHY this is happening now.
        - "fullCoverage": array of EXACTLY 3 objects with {"name": "Reuters", "angle": "Market reaction — shares rose 4%...", "stance": "Neutral", "headline": "Article headline from this source", "summary": "4-6 paragraph summary of this outlet's reporting. Cover the main event, key quotes, data points, and context. Write in neutral journalistic tone. Separate paragraphs with double newlines.", "date": "March 4, 2026", "sourceURL": "https://..."} — different outlets' perspectives. Stance must be one of: "Neutral", "Analytical", "Critical", "Positive". sourceURL must be a real, valid URL to the actual article. The "name" should use real outlet names like \(sourcesHint).
        - "whatToWatch": 1-2 sentences of forward-looking analysis — what could happen next, and what signals to watch for. Be specific: name dates, deadlines, decisions, or data releases.
        - "linkedTerms": array of 2-3 objects with {"term": "jargon word", "explanation": "plain English explanation"} — terms the average reader would NOT know. Prioritize: (1) proper nouns and named events/organizations the reader may never have heard of (e.g. "Global Baku Forum", "AUKUS"), (2) legal or technical terms (e.g. "DOJ subpoena", "quantitative easing"), (3) acronyms. Do NOT pick common phrases like "multilateral cooperation" or "diplomatic norms" — pick the terms a reader would actually Google.

        Return ONLY a single JSON object (NOT an array). No markdown, no code fences, just the raw JSON object.
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

        return try parseDeepContent(from: data)
    }

    private func parseDeepContent(from data: Data) throws -> DeepContent {
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
              let dict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw OpenRouterError.parsingFailed
        }

        let timelineArray: [TimelineEvent]? = (dict["timeline"] as? [[String: Any]])?.compactMap { t in
            guard let date = t["date"] as? String, let desc = t["description"] as? String else { return nil }
            return TimelineEvent(date: date, description: desc)
        }
        let coverageArray: [SourceCoverage]? = (dict["fullCoverage"] as? [[String: Any]])?.compactMap { c in
            guard let name = c["name"] as? String, let angle = c["angle"] as? String, let stance = c["stance"] as? String else { return nil }
            return SourceCoverage(name: name, angle: angle, stance: stance,
                                  headline: c["headline"] as? String,
                                  summary: c["summary"] as? String,
                                  date: c["date"] as? String,
                                  sourceURL: c["sourceURL"] as? String)
        }
        let termsArray: [LinkedTerm]? = (dict["linkedTerms"] as? [[String: Any]])?.compactMap { lt in
            guard let term = lt["term"] as? String, let explanation = lt["explanation"] as? String else { return nil }
            return LinkedTerm(term: term, explanation: explanation)
        }

        return DeepContent(
            timeline: timelineArray,
            fullCoverage: coverageArray,
            whatToWatch: dict["whatToWatch"] as? String,
            linkedTerms: termsArray
        )
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
            let timelineArray: [TimelineEvent]? = (dict["timeline"] as? [[String: Any]])?.compactMap { t in
                guard let date = t["date"] as? String, let desc = t["description"] as? String else { return nil }
                return TimelineEvent(date: date, description: desc)
            }
            let coverageArray: [SourceCoverage]? = (dict["fullCoverage"] as? [[String: Any]])?.compactMap { c in
                guard let name = c["name"] as? String, let angle = c["angle"] as? String, let stance = c["stance"] as? String else { return nil }
                return SourceCoverage(name: name, angle: angle, stance: stance,
                                      headline: c["headline"] as? String,
                                      summary: c["summary"] as? String,
                                      date: c["date"] as? String,
                                      sourceURL: c["sourceURL"] as? String)
            }
            let termsArray: [LinkedTerm]? = (dict["linkedTerms"] as? [[String: Any]])?.compactMap { lt in
                guard let term = lt["term"] as? String, let explanation = lt["explanation"] as? String else { return nil }
                return LinkedTerm(term: term, explanation: explanation)
            }
            let keyStat: KeyStat? = {
                guard let ks = dict["keyStat"] as? [String: Any],
                      let number = ks["number"] as? String,
                      let ctx = ks["context"] as? String else { return nil }
                return KeyStat(number: number, context: ctx)
            }()
            let keyFacts = dict["keyFacts"] as? [String]

            return Story(
                id: UUID(),
                headline: headline,
                category: category,
                categoryColor: Self.colorForCategory(category),
                hook: hook,
                context: context,
                soWhat: soWhat,
                deepDive: dict["deepDive"] as? String ?? (hook + " " + context),
                keyStat: keyStat,
                keyFacts: keyFacts,
                source: source,
                sourceURL: dict["sourceURL"] as? String ?? "",
                sources: dict["sources"] as? [String] ?? [source],
                readTime: dict["readTime"] as? String ?? "2 min read",
                timestamp: dict["timestamp"] as? String ?? "Today",
                imageURL: Self.imageURL(from: dict["imageURL"] as? String),
                timeline: timelineArray,
                fullCoverage: coverageArray,
                whatToWatch: dict["whatToWatch"] as? String,
                linkedTerms: termsArray
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
