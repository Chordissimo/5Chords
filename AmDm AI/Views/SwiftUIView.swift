//
//  SwiftUIView.swift
//  AmDm AI
//
//  Created by Anton on 04/05/2024.
//

import SwiftUI
import StoreKit

struct SwiftUIView: View {
    @State var showingSignIn: Bool = false
    
    var body: some View {
//        VStack {
//            Text("Welcome to my store")
//                .font(.title)
//
//            ProductView(id: "pro_chords_1299_1m_3d0") {
//                Image(systemName: "crown")
//            }
//            .productViewStyle(.compact)
//            .padding()
//            ProductView(id: "pro_chords_899_1y_3d0") {
//                Image(systemName: "crown")
//            }
//            .productViewStyle(.compact)
//            .padding()
//        }
//        VStack {
//            HStack {
//                StoreView(ids: ["pro_chords_1299_1m_3d0", "pro_chords_899_17_3d0"])
//                StoreView(ids: ["pro_chords_9999_1y_3d0", "pro_chords_899_17_3d0"])
//            }
//        }
        
        SubscriptionStoreView(productIDs:  ["pro_chords_9999_1y_3d0", "pro_chords_1299_1m_3d0"])
            .storeButton(.visible, for: .policies)
        
            .subscriptionStorePolicyDestination(for: .privacyPolicy) {
                Text("Privacy policy here")
            }
            .subscriptionStorePolicyDestination(for: .termsOfService) {
                Text("Terms of service here")
            }
            .subscriptionStoreControlStyle(.prominentPicker)
            .storeProductTask(for: "pro_chords_9999_1y_3d0") { taskState in
                print(taskState.product?.displayName ?? "")
            }
    }
}

#Preview {
    SwiftUIView()
}
