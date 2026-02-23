import Foundation
import SwiftUI

@Observable
class DailyBriefViewModel {
    var stories: [Story] = []
    var currentIndex: Int = 0
    var isLoading: Bool = false
    var error: String?

    private let apiService = OpenRouterService.shared
    private let cacheService = BriefCacheService.shared
    private let prefs = UserPreferencesService.shared

    var currentStory: Story? {
        guard currentIndex >= 0 && currentIndex < stories.count else { return nil }
        return stories[currentIndex]
    }

    var isComplete: Bool {
        !stories.isEmpty && currentIndex >= stories.count
    }

    var progress: String {
        "\(min(currentIndex + 1, stories.count)) of \(stories.count)"
    }

    func loadBrief() async {
        if let cached = cacheService.loadCachedBrief(), cached.isFromToday {
            stories = cached.stories
            currentIndex = 0
            return
        }
        await refreshBrief()
    }

    func refreshBrief() async {
        isLoading = true
        error = nil
        do {
            let fetched = try await apiService.fetchBrief(
                identityModes: prefs.selectedIdentityModes,
                energyMode: prefs.selectedEnergyMode
            )
            let brief = DailyBrief(
                stories: fetched,
                generatedAt: Date(),
                identityModes: prefs.selectedIdentityModes,
                energyMode: prefs.selectedEnergyMode
            )
            cacheService.saveBrief(brief)
            stories = fetched
            currentIndex = 0
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func nextStory() {
        if currentIndex < stories.count {
            currentIndex += 1
        }
    }

    func previousStory() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }

    func restart() {
        currentIndex = 0
    }
}
