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
    }

    var isOnboardingComplete: Bool {
        get { defaults.bool(forKey: Keys.onboardingComplete) }
        set { defaults.set(newValue, forKey: Keys.onboardingComplete) }
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
                return [.techAI, .politics]
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
