import Foundation
import SwiftUI

@Observable
class DailyBriefViewModel {
    var stories: [Story] = []
    var storiesRead: Set<UUID> = []
    var expandedStory: Story?
    var isLoading: Bool = false
    var error: String?

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
                      source: s.source, sourceURL: s.sourceURL,
                      sources: s.sources, readTime: s.readTime,
                      timestamp: s.timestamp, imageURL: s.imageURL)
            }
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
            let fetched = try await apiService.fetchBrief(
                topics: prefs.selectedTopics,
                energyMode: prefs.selectedEnergyMode,
                lifeStage: prefs.selectedLifeStage,
                motivation: prefs.selectedMotivation
            )
            let brief = DailyBrief(
                stories: fetched,
                generatedAt: Date(),
                topics: prefs.selectedTopics,
                energyMode: prefs.selectedEnergyMode
            )
            cacheService.saveBrief(brief)
            stories = fetched
            storiesRead = []
            UserDefaults.standard.removeObject(forKey: "storiesRead")
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
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
