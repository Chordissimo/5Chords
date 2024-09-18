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
    var renewalDate: Date? = nil
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

enum PaywallState {
    case eligibleForFreeTrial
    case noActiveSubscriptions

    case freeTrial
    case freeTrialCancelled
    case freeTrialBoughtMonthly

    case yearlyActivated
    case yearlyCancelled
    case yearlyActivatedBoughtMonthly

    case monthlyActivated
    case monthlyCancelled
    case monthlyActivatedBoughtYearly
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
    var subscriptions: [Subscription] = []
    
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
        switch self.paywallState {
        case .eligibleForFreeTrial, .noActiveSubscriptions:
            return nil
        case .freeTrial, .freeTrialCancelled, .freeTrialBoughtMonthly, .yearlyActivated, .yearlyCancelled, .yearlyActivatedBoughtMonthly:
            return self.subscriptions.filter { $0.billingPeriod == .year }.first
        case .monthlyActivated, .monthlyCancelled, .monthlyActivatedBoughtYearly:
            return self.subscriptions.filter { $0.billingPeriod == .month }.first
        }
    }
    
    var defaultSubscription: Subscription? {
        return self.subscriptions.filter { $0.isDefault }.first
    }
    
    var products: [Product] = []
    @Published var productInfoLoaded = false
    var isMock: Bool = false
    var updateListenerTask: Task<Void, Error>? = nil
    @Published var updatingSubscriptions: Bool = false
    @Published var paywallState: PaywallState = .eligibleForFreeTrial
    
    init(isMock: Bool = false) {
        self.isMock = isMock
        self.updateListenerTask = listenForTransactions()
    }
    
    func prepareStore() async {
        self.subscriptions = ProductModel.resetSubscriptions()
        if !isMock {
            await requestProducts()
            await loadSubScriptionInfo()
            await MainActor.run { productInfoLoaded = true }
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
    
    public static func resetSubscriptions() -> [Subscription] {
        return [
            Subscription(id: "pro_chords_9999_1y_3d0", isDefault: true, billingPeriod: .year),
            Subscription(id: "pro_chords_1299_1m_3d0", isDefault: false, billingPeriod: .month)
        ]
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.loadSubScriptionInfo()
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
                return await subscription.isEligibleForIntroOffer
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
                await transaction.finish()
                await self.loadSubScriptionInfo()
            default:
                print("failed to purchase: subscriptionId")
                return false
            }
        } catch {
            print("here:",error)
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
    
    func loadSubScriptionInfo() async {
        guard !self.isMock else { return }
        await MainActor.run { self.updatingSubscriptions = true }
        var subs: [Product.SubscriptionInfo.Status]?
        
        do {
            subs = try await Product.SubscriptionInfo.status(for: "21482440")
        } catch {
            print(error)
        }
        
        guard subs != nil else { return }
        self.subscriptions = ProductModel.resetSubscriptions()
        for p in self.products {
            if let index = self.subscriptions.firstIndex(where: { $0.id == p.id} ) {
                self.subscriptions[index].monthlyPrice = self.subscriptions[index].billingPeriod == .year ? p.priceFormatStyle.format(p.price / 12) + " mo" : ""
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
                
                let statuses = subs?.filter({
                    do {
                        return try $0.renewalInfo.payloadValue.currentProductID == p.id
                    } catch {
                        print(error)
                    }
                    return false
                })
                if let status = statuses?.first {
                    switch status.state {
                    case .subscribed, .inGracePeriod, .inBillingRetryPeriod:
                        do {
                            if let index = subscriptions.firstIndex(where: { $0.id == p.id} ) {
                                self.subscriptions[index].state = status.state
                                self.subscriptions[index].startDate = try status.transaction.payloadValue.signedDate
                                self.subscriptions[index].expirationDate = try status.transaction.payloadValue.expirationDate

                                self.subscriptions[index].renewProductId = try status.renewalInfo.payloadValue.autoRenewPreference ?? ""
                                self.subscriptions[index].renewalDate = try status.renewalInfo.payloadValue.renewalDate
                                self.subscriptions[index].expirationReason = try status.renewalInfo.payloadValue.expirationReason
                                self.subscriptions[index].willAutoRenew = try status.renewalInfo.payloadValue.willAutoRenew
                                self.subscriptions[index].isInTrialPeriod = try status.transaction.payloadValue.offerType == .introductory
                            }
                        } catch {
                            print(error)
                        }
                    default:
                        print("Unprocessed status")
                    }
                }
            }
        }

        await MainActor.run {
            self.paywallState = getPaywallState()

            if let currentSubscription = self.currentSubscription {
                AppDefaults.isLimited = currentSubscription.startDate == nil
            } else {
                AppDefaults.isLimited = true
            }
            self.updatingSubscriptions = false

            dump(self.subscriptions)
            print("paywallState:",self.paywallState)
        }
    }
    
    func getPaywallState() -> PaywallState {
        if let monthly = self.subscriptions.filter({ $0.billingPeriod == .month }).first,
           let yearly = self.subscriptions.filter({ $0.billingPeriod == .year }).first {
            
            if monthly.state == nil && yearly.state == nil && !yearly.isEligibleForFreeTrial {
                return
                    .noActiveSubscriptions
            }
            
            if let mState = monthly.state, let yState = yearly.state {
                if mState == .subscribed && yState == .subscribed {
                    if let mStart = monthly.startDate, let yEnd = yearly.expirationDate, let yStart = yearly.startDate, let mEnd = monthly.expirationDate {
                        if mStart >= yEnd {
                            if monthly.willAutoRenew {
                                return
                                    .monthlyActivated
                            } else {
                                return
                                    .monthlyCancelled
                            }
                        } else if yStart >= mEnd {
                            if yearly.willAutoRenew {
                                return
                                    .yearlyActivated
                            } else {
                                return
                                    .yearlyCancelled
                            }
                        }
                    }
                }
            } else if let yState = yearly.state {
                if yState == .subscribed {
                    if yearly.willAutoRenew {
                        if yearly.isInTrialPeriod {
                            if yearly.renewProductId == yearly.id {
                                return
                                    .freeTrial
                            } else {
                                return
                                    .freeTrialBoughtMonthly
                            }
                        } else {
                            if yearly.renewProductId == yearly.id {
                                return
                                    .yearlyActivated
                            } else {
                                return
                                    .yearlyActivatedBoughtMonthly
                            }
                        }
                    } else {
                        if yearly.isInTrialPeriod {
                            return
                                .freeTrialCancelled
                        } else {
                            return
                                .yearlyCancelled
                        }
                    }
                }
            } else if let mState = monthly.state {
                if mState == .subscribed {
                    if monthly.willAutoRenew {
                        if monthly.renewProductId == monthly.id {
                            return
                                .monthlyActivated
                        } else {
                            return
                                .monthlyActivatedBoughtYearly
                        }
                    } else {
                        return
                            .monthlyCancelled
                    }
                }
            }
        }
                        
        return .eligibleForFreeTrial
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
            await self.loadSubScriptionInfo()
        } catch {
            print(error)
        }
    }
    
    func showManageSubscriptions(subscriptionId: String) -> Bool {
        guard subscriptionId != "" else { return false }

        if let subscription = getSubscriptionBy(id: subscriptionId) {
            switch self.paywallState {
            case .freeTrial, .yearlyActivated:
                return subscription.billingPeriod == .year
                
            case .freeTrialBoughtMonthly, .monthlyActivated:
                return subscription.billingPeriod != .year
                
            case .monthlyActivatedBoughtYearly, .yearlyActivatedBoughtMonthly:
                return true
                
            default:
                return false
            }
        }
        return false
    }
    
    func getSubscribeButtonLabel(subscriptionId: String) -> String {
        var result: String = "Subscribe"
        guard subscriptionId != "" else { return result }
        
        if let subscription = getSubscriptionBy(id: subscriptionId) {
            switch self.paywallState {
            case .eligibleForFreeTrial:
                result = subscription.billingPeriod == .year ? "Start 7 Days free trial" : "Subscribe"
                
            case .freeTrial, .yearlyActivated:
                result = subscription.billingPeriod == .year ? "Manage subscriptions" : "Subscribe"
                
            case .freeTrialBoughtMonthly, .monthlyActivated:
                result = subscription.billingPeriod == .year ? "Subscribe" : "Manage subscriptions"
                
            case .noActiveSubscriptions:
                result = "Subscribe"

            case .yearlyCancelled, .freeTrialCancelled:
                result = subscription.billingPeriod == .year ? "Resubscribe" : "Subscribe"

            case .monthlyCancelled:
                result = subscription.billingPeriod == .year ? "Subscribe" : "Resubscribe"

            case .yearlyActivatedBoughtMonthly, .monthlyActivatedBoughtYearly:
                result = "Manage subscriptions"
            }
        }
        return result
    }
    
    func getSubscribeButtonColor(subscriptionId: String) -> Color {
        var result: Color = .progressCircle
        guard subscriptionId != "" else { return result }
        
        if let subscription = getSubscriptionBy(id: subscriptionId) {
            switch self.paywallState {
            case .freeTrial, .yearlyActivated:
                result = subscription.billingPeriod == .year ? .white : .progressCircle
                
            case .freeTrialBoughtMonthly, .monthlyActivated:
                result = subscription.billingPeriod == .year ? .progressCircle : .white
                
            case .eligibleForFreeTrial, .freeTrialCancelled, .monthlyCancelled, .yearlyCancelled, .noActiveSubscriptions:
                result = .progressCircle
                
            case .monthlyActivatedBoughtYearly, .yearlyActivatedBoughtMonthly:
                result = .white
            }
        }
        return result
    }
    
    func getMessageColor(subscriptionId: String) -> Color {
        var result: Color = .progressCircle
        guard subscriptionId != "" else { return result }
        
        if let subscription = getSubscriptionBy(id: subscriptionId) {
            switch self.paywallState {
            case .freeTrial, .yearlyActivated, .yearlyCancelled, .freeTrialCancelled, .yearlyActivatedBoughtMonthly, .freeTrialBoughtMonthly:
                result = subscription.billingPeriod == .year ? .progressCircle : .white
                
            case .monthlyActivated, .monthlyCancelled, .monthlyActivatedBoughtYearly:
                result = subscription.billingPeriod == .year ? .white : .progressCircle
                
            case .noActiveSubscriptions, .eligibleForFreeTrial:
                result = .white
                
            }
        }
        return result
    }
    
    func getMessage(subscriptionId: String) -> String {
        var result: String = "No commitement,\ncancel any time"
        guard subscriptionId != "" else { return result }
        
        if let subscription = getSubscriptionBy(id: subscriptionId) {
            let expDate = subscription.expirationDate?.formatted(date: .abbreviated, time: .omitted) ?? ""
            switch self.paywallState {
            case .eligibleForFreeTrial, .noActiveSubscriptions:
                result = "No commitement,\ncancel any time"
                
            case .freeTrialCancelled:
                result = subscription.billingPeriod == .year ? "7 Days Free trial\nExpires on \(expDate)" : "No commitement,\ncancel any time"
                
            case .freeTrial:
                result = subscription.billingPeriod == .year ? "7 Days Free trial\n" : "No commitement,\ncancel any time"
                
            case .freeTrialBoughtMonthly:
                result = subscription.billingPeriod == .year ? "7 Days Free trial\n" : "Begins after\nthe Free Trial expiration"
                
            case .monthlyActivated:
                result = subscription.billingPeriod == .year ? "No commitement,\ncancel any time" : "Subscribed.\nWill renew on \(expDate)"
                
            case .monthlyCancelled:
                result = subscription.billingPeriod == .year ? "No commitement,\ncancel any time" : "Expires on \(expDate)\n"
                
            case .yearlyActivated:
                result = subscription.billingPeriod == .year ? "Subscribed\nWill renew on \(expDate)" : "No commitement,\ncancel any time"
                
            case .yearlyCancelled:
                result = subscription.billingPeriod == .year ? "Expires on \(expDate)\n" : "No commitement,\ncancel any time"
                
            case .yearlyActivatedBoughtMonthly:
                result = subscription.billingPeriod == .year ? "Subscribed\nExpires on \(expDate)" : "Begins after the Yearly\nsubscription expiration"
                
            case .monthlyActivatedBoughtYearly:
                result = subscription.billingPeriod == .year ? "Begins after the Monthly\nsubscription expiration" : "Subscribed.\nExpires on \(expDate)"
            }
        }
        return result
    }
}
