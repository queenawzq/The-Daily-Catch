import Foundation

class UserPreferencesService {
    static let shared = UserPreferencesService()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let identityModes = "selectedIdentityModes"
        static let energyMode = "selectedEnergyMode"
        static let onboardingComplete = "onboardingComplete"
    }

    var isOnboardingComplete: Bool {
        get { defaults.bool(forKey: Keys.onboardingComplete) }
        set { defaults.set(newValue, forKey: Keys.onboardingComplete) }
    }

    var selectedIdentityModes: [IdentityMode] {
        get {
            guard let data = defaults.data(forKey: Keys.identityModes),
                  let modes = try? JSONDecoder().decode([IdentityMode].self, from: data) else {
                return [.founder]
            }
            return modes
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Keys.identityModes)
            }
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
