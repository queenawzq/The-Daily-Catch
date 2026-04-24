import Foundation

class UserPreferencesService {
    static let shared = UserPreferencesService()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let lifeStage = "selectedLifeStage"
        static let topics = "selectedTopics"
        static let motivation = "selectedMotivation"
        static let catchTime = "selectedCatchTime"
        static let energyMode = "selectedEnergyMode"
        static let onboardingComplete = "onboardingComplete"
        static let caughtUpCount = "caughtUpCount"
        static let hasPromptedForReview = "hasPromptedForReview"
        static let reviewPromptDeclinedAt = "reviewPromptDeclinedAt"
        static let notificationsEnabled = "notificationsEnabled"
        static let notificationHour = "notificationHour"
        static let notificationMinute = "notificationMinute"
        static let reengagementNotificationsEnabled = "reengagementNotificationsEnabled"
    }

    var isOnboardingComplete: Bool {
        get { defaults.bool(forKey: Keys.onboardingComplete) }
        set { defaults.set(newValue, forKey: Keys.onboardingComplete) }
    }

    var caughtUpCount: Int {
        get { defaults.integer(forKey: Keys.caughtUpCount) }
        set { defaults.set(newValue, forKey: Keys.caughtUpCount) }
    }

    var hasPromptedForReview: Bool {
        get { defaults.bool(forKey: Keys.hasPromptedForReview) }
        set { defaults.set(newValue, forKey: Keys.hasPromptedForReview) }
    }

    var reviewPromptDeclinedAt: Date? {
        get { defaults.object(forKey: Keys.reviewPromptDeclinedAt) as? Date }
        set { defaults.set(newValue, forKey: Keys.reviewPromptDeclinedAt) }
    }

    var notificationsEnabled: Bool {
        get { defaults.bool(forKey: Keys.notificationsEnabled) }
        set { defaults.set(newValue, forKey: Keys.notificationsEnabled) }
    }

    var reengagementNotificationsEnabled: Bool {
        get {
            if defaults.object(forKey: Keys.reengagementNotificationsEnabled) != nil {
                return defaults.bool(forKey: Keys.reengagementNotificationsEnabled)
            }
            return true // default on if the user allows notifications
        }
        set { defaults.set(newValue, forKey: Keys.reengagementNotificationsEnabled) }
    }

    // Defaults derived from selectedCatchTime the first time they're read.
    var notificationHour: Int {
        get {
            if defaults.object(forKey: Keys.notificationHour) != nil {
                return defaults.integer(forKey: Keys.notificationHour)
            }
            return defaultHourForCatchTime()
        }
        set { defaults.set(newValue, forKey: Keys.notificationHour) }
    }

    var notificationMinute: Int {
        get {
            if defaults.object(forKey: Keys.notificationMinute) != nil {
                return defaults.integer(forKey: Keys.notificationMinute)
            }
            return 0
        }
        set { defaults.set(newValue, forKey: Keys.notificationMinute) }
    }

    private func defaultHourForCatchTime() -> Int {
        switch selectedCatchTime {
        case .morning: return 8
        case .commute: return 9
        case .lunch: return 12
        case .evening: return 19
        case .none: return 8
        }
    }

    // Show the prompt once the user has hit "caught up" at least twice (shows they're returning),
    // hasn't been prompted yet, or was prompted and declined >60 days ago.
    var shouldShowReviewPrompt: Bool {
        guard caughtUpCount >= 2 else { return false }
        if hasPromptedForReview {
            guard let declinedAt = reviewPromptDeclinedAt else { return false }
            return Date().timeIntervalSince(declinedAt) > 60 * 24 * 60 * 60
        }
        return true
    }

    var selectedLifeStage: LifeStage? {
        get {
            guard let raw = defaults.string(forKey: Keys.lifeStage) else { return nil }
            return LifeStage(rawValue: raw)
        }
        set {
            defaults.set(newValue?.rawValue, forKey: Keys.lifeStage)
        }
    }

    var selectedTopics: [TopicInterest] {
        get {
            guard let data = defaults.data(forKey: Keys.topics),
                  let topics = try? JSONDecoder().decode([TopicInterest].self, from: data) else {
                return [.techAI, .politics, .businessStartups]
            }
            return topics
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Keys.topics)
            }
        }
    }

    var selectedMotivation: ReadingMotivation? {
        get {
            guard let raw = defaults.string(forKey: Keys.motivation) else { return nil }
            return ReadingMotivation(rawValue: raw)
        }
        set {
            defaults.set(newValue?.rawValue, forKey: Keys.motivation)
        }
    }

    var selectedCatchTime: CatchTime? {
        get {
            guard let raw = defaults.string(forKey: Keys.catchTime) else { return nil }
            return CatchTime(rawValue: raw)
        }
        set {
            defaults.set(newValue?.rawValue, forKey: Keys.catchTime)
        }
    }

    var selectedEnergyMode: EnergyMode {
        get {
            guard let raw = defaults.string(forKey: Keys.energyMode),
                  let mode = EnergyMode(rawValue: raw) else {
                return .quick
            }
            return mode
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.energyMode)
        }
    }
}
