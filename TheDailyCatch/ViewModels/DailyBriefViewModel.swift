import Foundation
import SwiftUI

@Observable
class DailyBriefViewModel {
    var stories: [Story] = []
    var storiesRead: Set<UUID> = []
    var expandedStory: Story?
    var isLoading: Bool = false
    var isLoadingDeepContent: Bool = false
    var error: String?
    var briefDate: Date?
    private var deepContentLoadedIds: Set<UUID> = []

    private let apiService = OpenRouterService.shared
    private let cacheService = BriefCacheService.shared
    private let prefs = UserPreferencesService.shared

    var allRead: Bool {
        !stories.isEmpty && storiesRead.count >= stories.count
    }

    var readCount: Int {
        storiesRead.count
    }

    func isRead(_ story: Story) -> Bool {
        storiesRead.contains(story.id)
    }

    func markRead(_ story: Story) {
        storiesRead.insert(story.id)
        saveReadState()
    }

    func expandStory(_ story: Story) {
        markRead(story)
        expandedStory = story
    }

    func collapseStory() {
        expandedStory = nil
    }

    func loadBrief() async {
        if let cached = cacheService.loadCachedBrief(), cached.isFromToday {
            stories = cached.stories.map { s in
                Story(id: s.id, headline: s.headline, category: s.category,
                      categoryColor: Self.colorForCategory(s.category),
                      hook: s.hook, context: s.context, soWhat: s.soWhat, deepDive: s.deepDive,
                      keyStat: s.keyStat, keyFacts: s.keyFacts,
                      source: s.source, sourceURL: s.sourceURL,
                      sources: s.sources, readTime: s.readTime,
                      timestamp: s.timestamp, imageURL: s.imageURL,
                      timeline: s.timeline, fullCoverage: s.fullCoverage,
                      whatToWatch: s.whatToWatch, linkedTerms: s.linkedTerms)
            }
            briefDate = cached.generatedAt
            loadReadState()
            return
        }
        await refreshBrief()
    }

    private static let categoryColorMap: [String: String] = [
        "MONEY": "D4A843", "TECH": "5B7FBF", "POLITICS": "C7685E",
        "CLIMATE": "5BA89E", "HEALTH": "6BAF7B", "CULTURE": "8E8FC7",
        "WORLD": "B07AA8", "BUSINESS": "B8705A", "SPORTS": "4A9EB5",
        "HOUSING": "C4A87A"
    ]

    private static func colorForCategory(_ category: String) -> String {
        categoryColorMap[category.uppercased()] ?? "3366FF"
    }

    func refreshBrief() async {
        isLoading = true
        error = nil
        do {
            // Try server first (pre-generated, fast), fall back to direct API
            let fetched: [Story]
            do {
                fetched = try await apiService.fetchBriefFromServer(
                    topics: prefs.selectedTopics,
                    energyMode: prefs.selectedEnergyMode
                )
                print("[DailyBrief] Loaded from server")
            } catch {
                print("[DailyBrief] Server fetch failed (\(error)), falling back to direct API")
                fetched = try await apiService.fetchBrief(
                    topics: prefs.selectedTopics,
                    energyMode: prefs.selectedEnergyMode,
                    lifeStage: prefs.selectedLifeStage,
                    motivation: prefs.selectedMotivation
                )
                print("[DailyBrief] Loaded from direct API")
            }
            let brief = DailyBrief(
                stories: fetched,
                generatedAt: Date(),
                topics: prefs.selectedTopics,
                energyMode: prefs.selectedEnergyMode
            )
            cacheService.saveBrief(brief)
            stories = fetched
            briefDate = brief.generatedAt
            storiesRead = []
            UserDefaults.standard.removeObject(forKey: "storiesRead")
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func hasDeepContent(for story: Story) -> Bool {
        deepContentLoadedIds.contains(story.id)
    }

    func loadDeepContent(for index: Int) async {
        let story = stories[index]
        guard !deepContentLoadedIds.contains(story.id) else { return }
        isLoadingDeepContent = true
        do {
            // Try server first, fall back to direct API
            let deep: OpenRouterService.DeepContent
            do {
                deep = try await apiService.fetchDeepContentFromServer(storyId: story.id.uuidString)
                print("[DailyBrief] Deep content loaded from server")
            } catch {
                print("[DailyBrief] Server deep fetch failed (\(error)), falling back to direct API")
                deep = try await apiService.fetchDeepContent(
                    headline: story.headline,
                    hook: story.hook,
                    context: story.context,
                    sources: story.sources
                )
                print("[DailyBrief] Deep content loaded from direct API")
            }
            stories[index].timeline = deep.timeline
            stories[index].fullCoverage = deep.fullCoverage
            stories[index].whatToWatch = deep.whatToWatch
            stories[index].linkedTerms = deep.linkedTerms
            deepContentLoadedIds.insert(story.id)
            // Update cache with deep content
            let brief = DailyBrief(
                stories: stories,
                generatedAt: briefDate ?? Date(),
                topics: prefs.selectedTopics,
                energyMode: prefs.selectedEnergyMode
            )
            cacheService.saveBrief(brief)
        } catch {
            // Silent fail — user can retry by toggling deep mode
        }
        isLoadingDeepContent = false
    }

    func restart() {
        storiesRead = []
        UserDefaults.standard.removeObject(forKey: "storiesRead")
        expandedStory = nil
    }

    private func saveReadState() {
        let ids = storiesRead.map { $0.uuidString }
        UserDefaults.standard.set(ids, forKey: "storiesRead")
    }

    private func loadReadState() {
        guard let ids = UserDefaults.standard.stringArray(forKey: "storiesRead") else { return }
        storiesRead = Set(ids.compactMap { UUID(uuidString: $0) })
    }
}
