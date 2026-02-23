import Foundation

struct DailyBrief: Codable {
    let stories: [Story]
    let generatedAt: Date
    let identityModes: [IdentityMode]
    let energyMode: EnergyMode

    var isFromToday: Bool {
        Calendar.current.isDateInToday(generatedAt)
    }
}
