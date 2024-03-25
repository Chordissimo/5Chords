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
    @State var user = User()
    
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
                
                PlansListView(user: $user)

                Spacer()
                
                Button("Limited version") {
                    print(user.registrationDate as Any, user.subscriptionPlanId as Any)
                }
                
            }.safeAreaPadding(.horizontal)
        }
    }
    

}

#Preview {
    Subscription()
}

struct PlansListView: View {
    @Binding var user: User
    
    var body: some View {
        VStack {
            ForEach(MockData.plans) { plan in
                SubscriptionPlanCard(title: plan.title, description: plan.description)
                    .onTapGesture {
                        user.selectPlan(registrationDate: Date(), subscriptionPlanId: plan.planId)
                    }
            }
        }
    }
}

struct SubscriptionPlanCard: View {
    let title: String
    let description: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 1.0))
            
            VStack {
                Text(title)
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.title)
                    .foregroundStyle(.white)
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(height: 150)
    }
}
