//
//  StoreKitManager.swift
//  AmDm AI
//
//  Created by Anton on 28/07/2024.
//

import SwiftUI
import StoreKit

public enum StoreError: Error {
    case failedVerification
}

// tutorial https://www.youtube.com/watch?v=jLA0r7cvePo
class StorekitManager: ObservableObject {
    var products: [Product] = []
    var isMock: Bool
    var productIds: [String]
//    var updateListenerTask: Task<Void, Error>? = nil
    
    init(productIds: [String], isMock: Bool = false) {
        self.productIds = productIds
        self.isMock = isMock
//        if !isMock {
//            self.updateListenerTask = listenForTransactions()
//        }
    }
    
//    deinit {
//        if !self.isMock {
//            updateListenerTask?.cancel()
//        }
//    }
    
//    func listenForTransactions() -> Task<Void, Error> {
//        return Task.detached {
//            for await result in Transaction.updates {
//                do {
//                    let transaction = try self.checkVerified(result)
//                    await self.getSubscriptionStatus()
//                    await transaction.finish()
//                } catch {
//                    print("Transaction failed verification")
//                }
//            }
//        }
//    }
    
    @MainActor
    func requestProducts() async {
        do {
            self.products = try await Product.products(for: self.productIds)
        } catch {
            print(error)
        }
    }
    
    func checkEligibilityForFreeTrial(id: String) async -> Bool {
        let p = self.products.filter({ $0.id == id })
        if p.count > 0 {
            if let subscription = p.first!.subscription {
                if let _ = subscription.introductoryOffer {
                    return await subscription.isEligibleForIntroOffer
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func purchase(_ productId: String) async throws -> Bool {
        guard !self.isMock else {
            return true
        }
        guard let product = products.first(where: { $0.id == productId }) else { return false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verificationResult):
            let transaction = try checkVerified(verificationResult)
            await transaction.finish()
//            await getSubscriptionStatus()
            return true
        case .userCancelled, .pending:
            return false
        default:
            return false
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let signedType):
            return signedType
        }
    }
    
//    func getSubscriptionStatus() async {
//        guard !self.isMock else { return }
//        var transactions: [StoreKit.Transaction] = []
//
//        for await result in Transaction.currentEntitlements {
//            do {
//                let transaction = try checkVerified(result)
//                transactions.append(transaction)
//            } catch {
//                print("Transaction failed verification")
//            }
//        }
//    }

}
