//
//  UserDataModel.swift
//  AmDm AI
//
//  Created by Anton on 25/03/2024.
//

import Foundation
import StoreKit
import SwiftUI

struct Subscription: Identifiable, Hashable {
    let id: String
    let isDefault: Bool
    let billingPeriod: BillingPeriod
    
    enum BillingPeriod: String {
        case year = "Yearly"
        case month = "Monthly"
        case none = ""
    }
}

struct ProductFeature: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var subscriptions: [String]
}

class ProductModel: ObservableObject {
    let subscriptions: [Subscription] = [
        Subscription(id: "pro_chords_9999_1y_3d0", isDefault: true, billingPeriod: .year),
        Subscription(id: "pro_chords_1299_1m_3d0", isDefault: false, billingPeriod: .month)
    ]

    let features: [ProductFeature] = [
        ProductFeature(
            name: "AI chords and lyrics recognition",
            subscriptions: ["pro_chords_9999_1y_3d0","pro_chords_1299_1m_3d0"]
        ),
        ProductFeature(
            name: "Unlimited songs in your collection",
            subscriptions: ["pro_chords_9999_1y_3d0","pro_chords_1299_1m_3d0"]
        ),
        ProductFeature(
            name: "Chord transposition",
            subscriptions: ["pro_chords_9999_1y_3d0","pro_chords_1299_1m_3d0"]
        ),
        ProductFeature(
            name: "Chord editing",
            subscriptions: ["pro_chords_9999_1y_3d0","pro_chords_1299_1m_3d0"]
        ),
        ProductFeature(
            name: "400+ guitar chord shapes",
            subscriptions: ["pro_chords_9999_1y_3d0","pro_chords_1299_1m_3d0"]
        ),
        ProductFeature(
            name: "Guitab, bass, and ukulele tuner",
            subscriptions: ["pro_chords_9999_1y_3d0","pro_chords_1299_1m_3d0"]
        ),

    ]

    var activeSubscriptionId: String {
        return self.store.activeSubscriptionId
    }
    @Published var productInfoLoaded = false
    @Published var store: StorekitManager
    
    init(isMock: Bool = false) {
        self.store = StorekitManager(productIds: ["pro_chords_9999_1y_3d0","pro_chords_1299_1m_3d0"], isMock: isMock)
        Task {
            await getSubscriptionStatus()
        }
    }
    
    func getSubscriptionBy(id: String) -> Subscription? {
        guard id != "" else { return nil }
        let result = subscriptions.filter { $0.id == id }
        return result.count > 0 ? result.first! : nil
    }
    
    func purchase(billingPeriod: Subscription.BillingPeriod) async -> Bool {
        var result = false
        @AppStorage("isLimited") var isLimited: Bool = false
        
        let subscriptionId = getSubscriptionIdBy(billingPeriod: billingPeriod)
        if subscriptionId != "" {
            do {
                result = try await store.purchase(subscriptionId)
                isLimited = !result
            } catch {
                print(error)
            }
        }
        return result
    }
    
    func getSubscriptionStatus() async {
        if !self.store.isMock {
            await self.store.getSubscriptionStatus()
            try! await AppStore.sync()
        }
        DispatchQueue.main.async {
            self.productInfoLoaded = true
        }
    }
    
    func getSubscriptionIdBy(billingPeriod: Subscription.BillingPeriod) -> String {
        let subs = self.subscriptions.filter { $0.billingPeriod == billingPeriod }
        return subs.count > 0 ? subs.first!.id : ""
    }
    
    func restoreSubscription() {
        Task {
            do {
                try await AppStore.sync()
            } catch {
                print(error)
            }
        }
    }
}

