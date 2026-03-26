import StoreKit
import SwiftUI

@Observable
@MainActor
final class StoreManager {
    static let shared = StoreManager()

    // MARK: - State

    var products: [Product] = []
    var hasActiveSubscription: Bool = false
    var isPurchasing: Bool = false
    var purchaseError: String?

    /// True if the user has a StoreKit subscription OR an active beta test code
    var isPremium: Bool {
        hasActiveSubscription || isBetaTester
    }

    // MARK: - Beta Testing

    var betaExpiryDate: Date? {
        get { UserDefaults.standard.object(forKey: "betaExpiryDate") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "betaExpiryDate") }
    }

    var isBetaTester: Bool {
        guard let expiry = betaExpiryDate else { return false }
        return expiry > Date()
    }

    var betaExpiryString: String? {
        guard let expiry = betaExpiryDate, expiry > Date() else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: expiry)
    }

    private let serverBaseURL = "https://the-daily-catch-server-production.up.railway.app"

    func redeemTestCode(_ code: String) async throws -> Date {
        guard let url = URL(string: "\(serverBaseURL)/api/redeem-code") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["code": code])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }

        guard json["valid"] as? Bool == true,
              let expiresAtString = json["expiresAt"] as? String else {
            let errorMsg = json["error"] as? String ?? "Invalid code"
            throw NSError(domain: "TestCode", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let expiryDate = formatter.date(from: expiresAtString) else {
            throw URLError(.cannotParseResponse)
        }

        betaExpiryDate = expiryDate
        return expiryDate
    }

    // MARK: - Product IDs

    private let monthlyID = "com.thedailycatch.deepcatch.monthly"
    private let yearlyID = "com.thedailycatch.deepcatch.yearly"
    // MARK: - Computed Helpers

    var monthlyProduct: Product? {
        products.first { $0.id == monthlyID }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == yearlyID }
    }

    var monthlyPriceString: String {
        monthlyProduct?.displayPrice ?? "$3.99"
    }

    var yearlyPriceString: String {
        yearlyProduct?.displayPrice ?? "$29.99"
    }

    var isEligibleForTrial: Bool {
        _trialEligible
    }

    private var _trialEligible: Bool = true

    // MARK: - Init

    private init() {
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
            await checkTrialEligibility()
        }
        Task(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if let transaction = try? self.checkVerified(result) {
                    await transaction.finish()
                    await self.updateSubscriptionStatus()
                }
            }
        }
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            products = try await Product.products(for: [monthlyID, yearlyID])
            print("[StoreManager] Loaded \(products.count) products: \(products.map { $0.id })")
        } catch {
            print("[StoreManager] Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async {
        isPurchasing = true
        purchaseError = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updateSubscriptionStatus()

            case .pending:
                purchaseError = "Purchase is pending approval."

            case .userCancelled:
                break

            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }

        isPurchasing = false
    }

    // MARK: - Update Subscription Status

    func updateSubscriptionStatus() async {
        var hasActive = false

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if transaction.productID == monthlyID || transaction.productID == yearlyID {
                    if transaction.revocationDate == nil {
                        hasActive = true
                    }
                }
            }
        }

        self.hasActiveSubscription = hasActive
        UserDefaults.standard.set(isPremium, forKey: "isPremium")
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            purchaseError = "Restore failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Trial Eligibility

    private func checkTrialEligibility() async {
        guard let product = yearlyProduct ?? monthlyProduct else { return }
        if let subscription = product.subscription {
            let eligible = await subscription.isEligibleForIntroOffer
            _trialEligible = eligible
        }
    }

    // MARK: - Verification Helper

    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }
}
