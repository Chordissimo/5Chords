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
    var billingPeriod: Product.SubscriptionPeriod.Unit
    var price: String = ""
    var fullPrice: String = ""
    var startDate: Date? = nil
    var expirationDate: Date? = nil
    var expirationReason: Product.SubscriptionInfo.RenewalInfo.ExpirationReason?
    var state: Product.SubscriptionInfo.RenewalState? = nil
    var willAutoRenew: Bool = false
    var renewProductId: String = ""
    var isEligibleForFreeTrial: Bool = false
    var isInTrialPeriod: Bool = false
    var trial: String = ""
    
    var billingPeriodLabel: String {
        switch self.billingPeriod {
        case .day:
            return "Daily"
        case .week:
            return "Weekly"
        case .month:
            return "Monthly"
        case .year:
            return "Yearly"
        default:
            return ""
        }
    }
}

struct ProductFeature: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var subscriptions: [String]
}

class ProductModel: ObservableObject {
    var subscriptions: [Subscription] = [
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
    
    var currentSubscription: Subscription? {
        return self.subscriptions.filter { $0.state == .subscribed && $0.expirationDate ?? Date() > Date() }.first
    }

    var defaultSubscription: Subscription? {
        return self.subscriptions.filter { $0.isDefault }.first
    }
    
    @Published var productInfoLoaded = false
    @Published var store: StorekitManager
    
    init(isMock: Bool = false) {
        self.store = StorekitManager(productIds: ["pro_chords_9999_1y_3d0","pro_chords_1299_1m_3d0"], isMock: isMock)
        Task {
            await self.loadSubScriptionInfo()
            await MainActor.run {
                print(self.subscriptions)
                self.verifySubscriptions()
                productInfoLoaded = true
            }
        }
    }
    
    func verifySubscriptions() {
        if let currentIndex = self.subscriptions.firstIndex(where: { $0.state == .subscribed }) {
            let currentId = self.subscriptions[currentIndex].id
            let renewId = self.subscriptions[currentIndex].renewProductId
            if currentId != renewId && renewId != "" {
                if let renewIndex = self.subscriptions.firstIndex(where: { $0.id == renewId }) {
                    self.subscriptions[renewIndex].startDate = self.subscriptions[currentIndex].expirationDate
                    self.subscriptions[renewIndex].state = .subscribed
                }
            }
        }
    }
    
    func loadSubScriptionInfo() async {
        await self.store.requestProducts()
        for p in self.store.products {
            if let index = self.subscriptions.firstIndex(where: { $0.id == p.id} ) {
                self.subscriptions[index].price = self.subscriptions[index].billingPeriod == .year ? p.priceFormatStyle.format(p.price / 12) : p.displayPrice
                self.subscriptions[index].fullPrice = p.displayPrice
                self.subscriptions[index].isEligibleForFreeTrial = await self.store.checkEligibilityForFreeTrial(id: p.id)
                self.subscriptions[index].billingPeriod = p.subscription?.subscriptionPeriod.unit ?? .year
                let intro = p.subscription?.introductoryOffer
                var trialPeriodDays = 0
                
                if intro != nil {
                    let trialUnit = intro!.period.unit
                    let moreThanOne = intro!.period.value > 1
                    switch trialUnit {
                    case .day:
                        self.subscriptions[index].trial = "\(intro!.period.value) days"
                        trialPeriodDays = intro!.period.value
                    case .week:
                        self.subscriptions[index].trial = "\(intro!.period.value * 7) days"
                        trialPeriodDays = intro!.period.value * 7
                    case .month:
                        self.subscriptions[index].trial = "\(intro!.period.value) month" + (moreThanOne ? "s" : "")
                        trialPeriodDays = intro!.period.value * 31 // <--- update to the number of days of current month if needed
                    case .year:
                        self.subscriptions[index].trial = "\(intro!.period.value) year"
                        trialPeriodDays = intro!.period.value * 365 // <--- update to the number of days of current year if needed
                    default:
                        self.subscriptions[index].trial = ""
                    }
                }

                if let verificationResult = await p.currentEntitlement {
                    switch verificationResult {
                    case .verified(let transaction):
                        if let status = await transaction.subscriptionStatus {
                            switch status.state {
                            case .subscribed, .inGracePeriod, .inBillingRetryPeriod:
                                do {
                                    if let index = subscriptions.firstIndex(where: { $0.id == p.id} ) {
                                        self.subscriptions[index].state = status.state
                                        self.subscriptions[index].startDate = transaction.signedDate
                                        self.subscriptions[index].expirationDate = transaction.expirationDate
                                        self.subscriptions[index].expirationReason = try status.renewalInfo.payloadValue.expirationReason
                                        self.subscriptions[index].willAutoRenew = try status.renewalInfo.payloadValue.willAutoRenew
                                        self.subscriptions[index].renewProductId = try status.renewalInfo.payloadValue.autoRenewPreference ?? ""
                                        if let start = self.subscriptions[index].startDate, let end = self.subscriptions[index].expirationDate {
                                            let diff = Int(round((end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate) / 60 / 60 / 24))
                                            self.subscriptions[index].isInTrialPeriod = diff == trialPeriodDays
                                        }
                                    }
                                } catch {
                                    print(error)
                                }
                            default:
                                #if DEBUG
                                print("Unprocessed status")
                                #endif
                            }
                        }
                    case .unverified(let transaction, let verificationError):
                        #if DEBUG
                        print("Unprocessed error:",transaction, verificationError)
                        #endif
                    }
                }
            }
        }
        if let currentSubscription = self.currentSubscription {
            if currentSubscription.startDate == nil {
                AppDefaults.isLimited = true
            }
        }
    }
    
    func getSubscriptionBy(id: String) -> Subscription? {
        guard id != "" else { return nil }
        let result = subscriptions.filter { $0.id == id }
        return result.count > 0 ? result.first! : nil
    }
    
    func purchase(subscriptionId: String) async -> Bool {
        guard subscriptionId != "" else { return false }
        var result = false

        do {
            result = try await store.purchase(subscriptionId)
            await self.loadSubScriptionInfo()
            AppDefaults.isLimited = !result
        } catch {
            print(error)
        }

        return result
    }
    
//    func getSubscriptionStatus() async {
//        if !self.store.isMock {
//            await self.store.getSubscriptionStatus()
//            try! await AppStore.sync()
//        }
//        DispatchQueue.main.async {
//            self.productInfoLoaded = true
//        }
//    }

    func getSubscriptionIdBy(subscriptionId: String) -> Subscription? {
        return self.subscriptions.filter { $0.id == subscriptionId }.first
    }

    func restoreSubscription() async {
        do {
            try await AppStore.sync()
        } catch {
            print(error)
        }
    }
    
    func getSubscribeButtonLabel(subscriptionId: String) -> String {
        let result: String = "Subscribe"
        guard subscriptionId != "" else { return result }
        
        if let subscription = getSubscriptionBy(id: subscriptionId) {
            let isSubscribed = subscription.state == .subscribed
            if isSubscribed {
                if subscription.willAutoRenew {
                    return "Manage subscription"
                } else {
                    if (subscription.startDate ?? Date()) > Date() {
                        return "Manage subscription"
                    }
                }
            } else {
                if subscription.isEligibleForFreeTrial {
                    return "Start \(subscription.trial) Free Trial"
                }
            }
        }            
        return result
    }
    
    func getMessage(subscriptionId: String) -> String {
        var result: String = "No commitement,\ncancel any time"
        guard subscriptionId != "" else { return result }

        if let subscription = getSubscriptionBy(id: subscriptionId) {
            if let state = subscription.state {
                switch state {
                case .inBillingRetryPeriod: result = "Subscribed. Ongoing issue with your payment."
                case .inGracePeriod: result = "Subscribed. Pending renewal."
                case .subscribed:
                    let startDate = subscription.startDate?.formatted(date: .abbreviated, time: .omitted) ?? ""
                    let expDate = subscription.expirationDate?.formatted(date: .abbreviated, time: .omitted) ?? ""
                    
                    if subscription.isInTrialPeriod {
                        if subscription.renewProductId == subscription.id || subscription.renewProductId == "" {
                            if subscription.willAutoRenew {
                                result = "Trial period\nYou will be charged on \(expDate)"
                            } else {
                                let reason = subscription.expirationReason == .autoRenewDisabled ? "Canceled\n" : ""
                                result = "\(reason)Trial period expires on\n\(expDate)"
                            }
                        } else {
                            result = "Trial period\nExpires on \(expDate)"
                        }
                    } else {
                        if let start = subscription.startDate {
                            if start <= Date() {
                                if subscription.renewProductId == subscription.id || subscription.renewProductId == "" {
                                    if subscription.willAutoRenew {
                                        result = "Subscribed\nWill renews on \(expDate)"
                                    } else {
                                        let reason = subscription.expirationReason == .autoRenewDisabled ? "Canceled\n" : ""
                                        result = "\(reason)Subscription expires on \(expDate)"
                                    }
                                } else {
                                    result = "Subscription expires on\n\(expDate)"
                                }
                            } else {
                                result = "Subscription starts on\n\(startDate)"
                            }
                        }
                    }
                default: result = ""
                }
            }
        }
        return result
    }
}

