//
//  Subscription.swift
//  AmDm AI
//
//  Created by Anton on 25/03/2024.
//

import SwiftUI
import SwiftData

struct Subscription: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var user: User

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            
            Color.black.ignoresSafeArea()
                
            VStack {
                HStack {
                    Text("AmDm ai")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.white)
                    
                }
                
                Image(systemName: "waveform.path")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .colorInvert()
                    .frame(width: 80, height: 80)
                    .padding()
                
                ForEach(MockData.plans) { plan in
                    if(plan.planId > 0) {
                        SubscriptionPlanCard(title: plan.title, description: plan.description)
                            .onTapGesture {
                                user.selectPlan(registrationDate: Date(), subscriptionPlanId: plan.planId)
                            }
                    }
                }
                
                Spacer()
                
                Button("Limited version") {
                    user.selectPlan(registrationDate: Date(), subscriptionPlanId: 0)
                }
            }

        }
    }
    

}

//#Preview {
//    Subscription()
//}
