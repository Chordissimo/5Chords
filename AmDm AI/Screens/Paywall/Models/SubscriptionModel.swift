//
//  UserDataModel.swift
//  AmDm AI
//
//  Created by Anton on 25/03/2024.
//

import Foundation
import StoreKit
import SwiftUI

struct ProductConfiguration: Identifiable, Equatable {
    let id = UUID()
    let planId: String
    let title: String
    let description: String
    let tagLine: String
    let displayPrice: String
    let isPreferable: Bool
    var isActive: Bool = false
    let productPriority: Int
    let billingPeriod: BillingPeriod
    var startDate: Date? = nil
    
    enum BillingPeriod {
        case year
        case month
    }
}

public enum StoreError: Error {
    case failedVerification
}

// tutorial https://www.youtube.com/watch?v=jLA0r7cvePo
class StorekitManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var productConfig: [ProductConfiguration] = []
    let productIds: [String] = ["pro_chords_9999_1y_3d0","pro_chords_1299_1m_3d0"]
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
            self.products = try await Product.products(for: self.productIds)
        } catch {
            print(error)
        }
        
        if let productOne = products.first(where: { $0.id == self.productIds[0] }) {
            self.productConfig.append(ProductConfiguration(
                planId: "pro_chords_9999_1y_3d0",
                title: productOne.displayName,
                description: "12 month • " + productOne.displayPrice,
                tagLine: "Save 36%",
                displayPrice: String(format: "%.2f", (productOne.price as CVarArg) as! Double / 12.0) + " / month",
                isPreferable: true,
                productPriority: 1,
                billingPeriod: .year
            ))
        }
        
        if let productTwo = products.first(where: { $0.id == self.productIds[1] }) {
            self.productConfig.append(ProductConfiguration(
                planId: "pro_chords_1299_1m_3d0",
                title: productTwo.displayName,
                description: "",
                tagLine: "",
                displayPrice: productTwo.displayPrice + " / month",
                isPreferable: false,
                productPriority: 0,
                billingPeriod: .month
            ))
        }
    }
    
    func purchase(_ productId: String) async throws -> StoreKit.Transaction? {
        guard let product = products.first(where: { $0.id == productId }) else { return nil}
        let result = try await product.purchase()
        
        switch result {
        case .success(let verificationResult):
            let transaction = try checkVerified(verificationResult)
            await transaction.finish()
            await updateCustomerProductStatus()
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
        var transactions: [StoreKit.Transaction] = []
        @AppStorage("isLimited") var isLimited: Bool = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                transactions.append(transaction)
            } catch {
                print("Transaction failed verification")
            }
        }
        
        if transactions.count > 0 {
            let latestActiveTransactions = transactions.filter { t in
                t.expirationDate ?? Date() > Date()
            }

            if latestActiveTransactions.count > 0 {
                let status = await latestActiveTransactions[0].subscriptionStatus
                do {
                    if let activeProductIndex = productConfig.firstIndex(where: { $0.planId == latestActiveTransactions[0].productID}) {
                        for i in 0..<productConfig.count {
                            self.productConfig[i].isActive = activeProductIndex == i
                            if activeProductIndex == i {
                                isLimited = false
                            }
                        }
                        let autoRenewProductId = try status?.renewalInfo.payloadValue.autoRenewPreference
                        if autoRenewProductId != self.productConfig[activeProductIndex].planId {
                            if let productIndex = productConfig.firstIndex(where: { $0.planId == autoRenewProductId}) {
                                self.productConfig[productIndex].startDate = latestActiveTransactions[0].expirationDate
                            }
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
}
