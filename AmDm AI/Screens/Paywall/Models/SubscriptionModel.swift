//
//  UserDataModel.swift
//  AmDm AI
//
//  Created by Anton on 25/03/2024.
//

import Foundation
import StoreKit

//final class User: ObservableObject {
//    var registrationDate: Date?
//    var subscriptionPlanId: Int = 0
//    var accessDisallowed: Bool = false
//    
//    init() {}
//    
//    func selectPlan(registrationDate: Date, subscriptionPlanId: Int) {
//        self.registrationDate = registrationDate
//        self.subscriptionPlanId = subscriptionPlanId
//        self.accessDisallowed = false
//    }
//    
//}
//
//struct SubscriptionPlan: Identifiable, Hashable {
//    let id = UUID()
//    let planId: Int
//    let title: String
//    let description: String
//    let price: Float
//}
//
//struct MockData: Hashable {
//    static let plans = [
//        SubscriptionPlan(planId: 0, title: "Limited version", description: "Description", price: 0.0),
//        SubscriptionPlan(planId: 1, title: "Plan A", description: "Description", price: 1.0),
//        SubscriptionPlan(planId: 2, title: "Plan B", description: "Description", price: 4.99),
//        SubscriptionPlan(planId: 3, title: "Plan C", description: "Description", price: 9.99)
//    ]
//}


struct ProductConfiguration: Identifiable, Equatable {
    let id = UUID()
    let planId: String
    let title: String
    let description: String
    let tagLine: String
    let displayPrice: String
    let isPreferable: Bool
    var isPurchased: Bool = false
}

public enum StoreError: Error {
    case failedVerification
}

// tutorial https://www.youtube.com/watch?v=jLA0r7cvePo
class StorekitManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var productConfig: [ProductConfiguration] = []
    var updateListenerTask: Task<Void, Error>? = nil
    
    init() {
        self.updateListenerTask = listenForTransactions()
        
        Task {
            await requestProducts()
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updateCustomerProductStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    @MainActor
    func requestProducts() async {
        do {
            self.products = try await Product.products(for: ["pro_chords_9999_1y_3d0","pro_chords_1299_1m_3d0"])
        } catch {
            print(error)
        }
        
        if let productOne = products.first(where: { $0.id == "pro_chords_9999_1y_3d0" }) {
            self.productConfig.append(ProductConfiguration(
                planId: "pro_chords_9999_1y_3d0",
                title: productOne.displayName,
                description: "12 month • " + productOne.displayPrice,
                tagLine: "Save 36%",
                displayPrice: String(format: "%.2f", (productOne.price as CVarArg) as! Double / 12.0) + " / month",
                isPreferable: true
            ))
        }
        
        if let productTwo = products.first(where: { $0.id == "pro_chords_1299_1m_3d0" }) {
            self.productConfig.append(ProductConfiguration(
                planId: "pro_chords_1299_1m_3d0",
                title: productTwo.displayName,
                description: "",
                tagLine: "",
                displayPrice: productTwo.displayPrice + " / month",
                isPreferable: false
            ))
        }
    }
    
    func purchase(_ productId: String) async throws -> Transaction? {
        guard let product = products.first(where: { $0.id == productId }) else { return nil}
        let result = try await product.purchase()
        
        switch result {
        case .success(let verificationResult):
            let transaction = try checkVerified(verificationResult)
            await updateCustomerProductStatus()
            await transaction.finish()
            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
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
    
    @MainActor
    func updateCustomerProductStatus() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if let productIndex = productConfig.firstIndex(where: { $0.planId == transaction.productID}) {
                    self.productConfig[productIndex].isPurchased = true
                }
            } catch {
                print("Transaction failed verification")
            }
        }
    }

}
