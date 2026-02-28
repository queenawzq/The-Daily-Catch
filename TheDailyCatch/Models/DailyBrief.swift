import Foundation

struct DailyBrief: Codable {
    let stories: [Story]
    let generatedAt: Date
    let topics: [TopicInterest]
    let energyMode: EnergyMode

    var isFromToday: Bool {
        Calendar.current.isDateInToday(generatedAt)
    }
}
