//
//  StoreManager.swift
//  Світ Казок
//

import Foundation
import StoreKit

enum StorePurchaseError: Error {
    case productUnavailable
    case verificationFailed
    case userCancelled
    case pending
    case unknown
}

@Observable
final class StoreManager {
    static let premiumProductID = "com.sebastianstrus.fairytales.premium"
    static let freeStoryLimit = 3

    private(set) var products: [Product] = []
    private(set) var isPremium: Bool = false
    private(set) var isLoadingProducts: Bool = false
    private(set) var isPurchasing: Bool = false
    private(set) var lastError: String?

    private var updatesTask: Task<Void, Never>?

    var premiumProduct: Product? {
        products.first(where: { $0.id == Self.premiumProductID })
    }

    init() {
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                await self?.handle(transactionResult: update)
            }
        }
        Task { await refreshPremiumStatus() }
    }

    deinit {
        updatesTask?.cancel()
    }

    func isLocked(storyNumber: Int) -> Bool {
        guard !isPremium else { return false }
        return storyNumber > Self.freeStoryLimit
    }

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        await fetchProductsWithRetry(attempts: 3)
    }

    private func fetchProductsWithRetry(attempts: Int) async {
        for attempt in 0..<attempts {
            do {
                let fetched = try await Product.products(for: [Self.premiumProductID])
                if !fetched.isEmpty {
                    products = fetched
                    lastError = nil
                    return
                }
            } catch {
                lastError = error.localizedDescription
            }
            if attempt < attempts - 1 {
                let delayNs = UInt64(pow(2.0, Double(attempt)) * 400_000_000)
                try? await Task.sleep(nanoseconds: delayNs)
            }
        }
        if products.isEmpty && lastError == nil {
            lastError = "Не вдалося завантажити продукт. Перевір з'єднання і спробуй ще раз."
        }
    }

    @discardableResult
    func purchasePremium() async -> Bool {
        if premiumProduct == nil {
            await loadProducts()
        }
        guard let product = premiumProduct else {
            if lastError == nil {
                lastError = "Продукт недоступний. Спробуй ще раз за мить."
            }
            return false
        }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                isPremium = true
                lastError = nil
                return true
            case .userCancelled:
                return false
            case .pending:
                lastError = "Покупка очікує на затвердження."
                return false
            @unknown default:
                return false
            }
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshPremiumStatus()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func refreshPremiumStatus() async {
        var unlocked = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.premiumProductID,
               transaction.revocationDate == nil {
                unlocked = true
            }
        }
        isPremium = unlocked
    }

    private func handle(transactionResult: VerificationResult<Transaction>) async {
        do {
            let transaction = try checkVerified(transactionResult)
            if transaction.productID == Self.premiumProductID,
               transaction.revocationDate == nil {
                isPremium = true
            } else {
                await refreshPremiumStatus()
            }
            await transaction.finish()
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StorePurchaseError.verificationFailed
        case .verified(let value):
            return value
        }
    }
}
