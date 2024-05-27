//
//  UserDataModel.swift
//  AmDm AI
//
//  Created by Anton on 25/03/2024.
//

import Foundation
import StoreKit

final class User: ObservableObject {
    var registrationDate: Date?
    var subscriptionPlanId: Int = 0
    var accessDisallowed: Bool = false
    
    init() {}
    
    func selectPlan(registrationDate: Date, subscriptionPlanId: Int) {
        self.registrationDate = registrationDate
        self.subscriptionPlanId = subscriptionPlanId
        self.accessDisallowed = false
    }
    
}

struct SubscriptionPlan: Identifiable, Hashable {
    let id = UUID()
    let planId: Int
    let title: String
    let description: String
    let price: Float
}

struct MockData: Hashable {
    static let plans = [
        SubscriptionPlan(planId: 0, title: "Limited version", description: "Description", price: 0.0),
        SubscriptionPlan(planId: 1, title: "Plan A", description: "Description", price: 1.0),
        SubscriptionPlan(planId: 2, title: "Plan B", description: "Description", price: 4.99),
        SubscriptionPlan(planId: 3, title: "Plan C", description: "Description", price: 9.99)
    ]
}


// tutorial https://www.youtube.com/watch?v=jLA0r7cvePo
//class StorekitManager: ObservableObject {
//    @Published var products: [Product] = []
//    @Published var activeSubscription: Product
    
//    private let productList: [String : String]
//    
//    init() {
//        
//    }
//    
//    subscribe(productId: Int) {
//
//    }
//}
