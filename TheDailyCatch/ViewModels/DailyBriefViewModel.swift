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
                      hook: s.hook, context: s.context, soWhat: s.soWhat,
                      source: s.source, sourceURL: s.sourceURL,
                      sources: s.sources, readTime: s.readTime,
                      timestamp: s.timestamp, imageURL: s.imageURL)
            }
            return
        }
        await refreshBrief()
    }

    private static let categoryColorMap: [String: String] = [
        "MONEY": "E8B84B", "TECH": "3366FF", "POLITICS": "FF6B5A",
        "CLIMATE": "4ECDC4", "HEALTH": "4ECDC4", "CULTURE": "7B9BFF",
        "WORLD": "FF6B5A", "BUSINESS": "E8B84B", "SPORTS": "3366FF",
        "HOUSING": "7B9BFF"
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
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func restart() {
        storiesRead = []
        expandedStory = nil
    }
}
