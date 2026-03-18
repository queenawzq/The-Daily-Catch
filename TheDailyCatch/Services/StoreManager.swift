import StoreKit
import SwiftUI

@Observable
@MainActor
final class StoreManager {
    static let shared = StoreManager()

    // MARK: - State

    var products: [Product] = []
    var isPremium: Bool = false
    var isPurchasing: Bool = false
    var purchaseError: String?

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
        var hasActiveSubscription = false

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if transaction.productID == monthlyID || transaction.productID == yearlyID {
                    if transaction.revocationDate == nil {
                        hasActiveSubscription = true
                    }
                }
            }
        }

        isPremium = hasActiveSubscription
        UserDefaults.standard.set(hasActiveSubscription, forKey: "isPremium")
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
