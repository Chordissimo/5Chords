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
    var monthlyPrice: String = ""
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

public enum StoreError: Error {
    case failedVerification
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
    
    var products: [Product] = []
    @Published var productInfoLoaded = false
    var isMock: Bool = false
    var updateListenerTask: Task<Void, Error>? = nil
    @Published var updatingSubscriptions: Bool = false
    
    init(isMock: Bool = false) {
        self.isMock = isMock
        if !isMock {
            self.updateListenerTask = listenForTransactions()
            Task {
                for await result in Transaction.currentEntitlements {
                    do {
                        let transaction = try checkVerified(result)
                        print("init",transaction)
                        await transaction.finish()
                    } catch {
                        print("Transaction failed verification")
                    }
                }
                await loadSubScriptionInfo()
                await MainActor.run {
                    self.verifySubscriptions()
                    print("init",self.subscriptions)
                    productInfoLoaded = true
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.productInfoLoaded = true
            }
        }
    }
    
    deinit {
        if !self.isMock {
            updateListenerTask?.cancel()
        }
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    print("listener",transaction)
                    await self.loadSubScriptionInfo()
                    await MainActor.run {
                        self.verifySubscriptions()
                        print("listener",self.subscriptions)
                    }
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    @MainActor
    func requestProducts() async {
        guard self.subscriptions.count > 0 else { return }
        let productIds = self.subscriptions.map { $0.id }
        do {
            self.products = try await Product.products(for: productIds)
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
    
    func purchase(subscriptionId: String) async -> Bool {
        guard let product = self.products.first(where: { $0.id == subscriptionId }) else { return false }
        var result = true
        
        if self.isMock {
            if let index = self.subscriptions.firstIndex(where: { $0.id == subscriptionId }) {
                let interval = self.subscriptions[index].billingPeriod == .month ? 30 : 365
                let expDate = Date() + TimeInterval(interval * 24 * 60 * 60)
                self.subscriptions[index].startDate = Date()
                self.subscriptions[index].expirationDate = expDate
                self.subscriptions[index].trial = ""
                self.subscriptions[index].state = .subscribed
                self.subscriptions[index].willAutoRenew = true
                return result
            }
        }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                let transaction = try checkVerified(verificationResult)
                print("purchase",transaction)
                await transaction.finish()
                AppDefaults.isLimited = false
            default:
                AppDefaults.isLimited = true
            }
        } catch {
            print(error)
            result = false
        }
        
        return result
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let signedType):
            return signedType
        }
    }
    
    func verifySubscriptions() {
        guard !self.isMock else { return }
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
        guard !self.isMock else { return }
        await MainActor.run { self.updatingSubscriptions = true }
        await self.requestProducts()
        for p in self.products {
            if let index = self.subscriptions.firstIndex(where: { $0.id == p.id} ) {
                self.subscriptions[index].monthlyPrice = self.subscriptions[index].billingPeriod == .year ? p.priceFormatStyle.format(p.price / 12) : ""
                self.subscriptions[index].fullPrice = p.displayPrice
                self.subscriptions[index].isEligibleForFreeTrial = await self.checkEligibilityForFreeTrial(id: p.id)
                self.subscriptions[index].billingPeriod = p.subscription?.subscriptionPeriod.unit ?? .year
                
                if let intro = p.subscription?.introductoryOffer {
                    let trialUnit = intro.period.unit
                    let moreThanOne = intro.period.value > 1
                    switch trialUnit {
                    case .day:
                        self.subscriptions[index].trial = "\(intro.period.value) days"
                    case .week:
                        self.subscriptions[index].trial = "\(intro.period.value * 7) days"
                    case .month:
                        self.subscriptions[index].trial = "\(intro.period.value) month" + (moreThanOne ? "s" : "")
                    case .year:
                        self.subscriptions[index].trial = "\(intro.period.value) year"
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
                                        self.subscriptions[index].isInTrialPeriod = transaction.offerType == .introductory
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
            AppDefaults.isLimited = currentSubscription.startDate == nil
        } else {
            AppDefaults.isLimited = true
        }
        await MainActor.run { self.updatingSubscriptions = false }
    }
    
    func getSubscriptionBy(id: String) -> Subscription? {
        guard id != "" else { return nil }
        let result = subscriptions.filter { $0.id == id }
        return result.count > 0 ? result.first! : nil
    }

    func getSubscriptionIdBy(subscriptionId: String) -> Subscription? {
        return self.subscriptions.filter { $0.id == subscriptionId }.first
    }

    func restoreSubscription() async {
        guard !self.isMock else { return }
        do {
            try await AppStore.sync()
            await self.requestProducts()
            await self.loadSubScriptionInfo()
            await MainActor.run {
                self.verifySubscriptions()
            }
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
                                result = "You will be charged on \(expDate)\nafter trial period expiration "
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
                                        result = "Subscribed\nWill renew on \(expDate)"
                                    } else {
                                        let reason = subscription.expirationReason == .autoRenewDisabled ? "Canceled\n" : ""
                                        result = "\(reason)Subscription expires on\n\(expDate)"
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

