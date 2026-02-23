import Foundation

class BriefCacheService {
    static let shared = BriefCacheService()

    private var cacheURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("daily_brief_cache.json")
    }

    func loadCachedBrief() -> DailyBrief? {
        guard FileManager.default.fileExists(atPath: cacheURL.path) else { return nil }
        guard let data = try? Data(contentsOf: cacheURL) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(DailyBrief.self, from: data)
    }

    func saveBrief(_ brief: DailyBrief) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(brief) else { return }
        try? data.write(to: cacheURL)
    }

    func clearCache() {
        try? FileManager.default.removeItem(at: cacheURL)
    }
}
