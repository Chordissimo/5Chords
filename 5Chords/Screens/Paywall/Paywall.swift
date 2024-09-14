//
//  Paywall.swift
//  AmDm AI
//
//  Created by Anton on 26/07/2024.
//

import SwiftUI
import StoreKit

struct Paywall: View  {
    var appDefaults = AppDefaults()
    @EnvironmentObject var store: ProductModel
    @Binding var showPaywall: Bool
    @Environment(\.openURL) var openURL
    @State var selectedSubscriptionId: String = ""
    @State var currentSubscriptionId: String = ""
    @State var message: String = ""
    @State var colorTrigger: Bool = false
    var completion: () -> Void = {}
        
    var body: some View {
        VStack(spacing: 0) {
            /// MARK: Header
            VStack {
                HStack {
                    Button {
                        AppDefaults.isLimited = (store.currentSubscription?.id ?? "") == ""
                        showPaywall = false
                        completion()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                            .foregroundColor(.white)
                            .opacity(0.5)
                    }
                    Spacer()
                    Button {
                        Task {
                            await store.restoreSubscription()
                        }
                    } label: {
                        Text("Restore")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                            .font(.system(size: 20))
                    }
                }
                .padding(.top, AppDefaults.topSafeArea)
                .padding(.horizontal, 20)
            }
            
            /// MARK: App name
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("5")
                        .font(.custom("TitanOne", size: 60))
                        .foregroundStyle(.progressCircle)
                    Text("CHORDS")
                        .fontWeight(.semibold)
                        .fontWidth(.expanded)
                        .font(.system(size: 38))
                }
                Text("POWERED BY AI")
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                    .foregroundStyle(.secondaryText)
                    .font(.system(size: 11))
            }
            .padding(.vertical,40)
            
            /// MARK: Billing period selection
            VStack {
                HStack(spacing: 0) {
                    ForEach(store.subscriptions, id: \.self) { subscription in
                        Button {
                            selectedSubscriptionId = subscription.id
                        } label: {
                            Text(subscription.billingPeriodLabel)
                                .fontWeight(.semibold)
                                .foregroundStyle(selectedSubscriptionId == subscription.id ? Color.black : Color.white)
                                .frame(width: (AppDefaults.screenWidth - 40) / 2, height: 40)
                        }
                        .background(selectedSubscriptionId == subscription.id ? Color.white : Color.clear, in: Capsule())
                    }
                }
                .background(Color.gray20)
                .clipShape(.rect(cornerRadius: 20))
                .padding(.horizontal, 20)
            }
            .frame(width: AppDefaults.screenWidth)
            
            /// MARK: Price tag
            VStack {
                let subscription = store.getSubscriptionBy(id: selectedSubscriptionId)
                let monthlyPrice = subscription?.monthlyPrice ?? "" == "" ? "" : subscription?.monthlyPrice ?? "" + " mo"
                let price = subscription?.fullPrice ?? ""
                let billingPeriod = subscription == nil ? "" : (subscription!.billingPeriod == .year ? "billed annually" : "billed monthly")
                
                HStack(alignment: .bottom, spacing: 0) {
                    Text(price)
                        .font(.system(size: 24))
                        .fontWeight(.semibold)
                    Text(monthlyPrice != "" ? "\\" : "")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray40)
                        .fontWeight(.bold)
                        .padding(.bottom, monthlyPrice != "" ? 4 : 0)
                        .padding(.leading, monthlyPrice != "" ? 7 : 0)
                        .padding(.trailing, monthlyPrice != "" ? 4 : 0)
                    Text(monthlyPrice != "" ? monthlyPrice : "")
                        .font(.system(size: 20))
                        .foregroundStyle(.gray40)
                        .fontWeight(.semibold)
                }
                .frame(height: 30)
                Text(billingPeriod)
                    .fontWidth(.expanded)
                    .foregroundStyle(.secondaryText)
                    .font(.system(size: 11))
                Text(message)
                    .foregroundStyle(colorTrigger ? .progressCircle : .white)
                    .font(.system(size: 14))
                    .fontWeight(colorTrigger ? .bold : .regular)
                    .padding(.top, 10)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 20)
            
            /// MARK: Product features
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "crown.fill")
                        .resizable()
                        .foregroundColor(.grad2)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 16)
                    Text("Premium features")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(Color.progressCircle)
                
                VStack {
                    ScrollView(.vertical) {
                        ForEach(store.features, id: \.self) { feature in
                            HStack {
                                Text(feature.name)
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(Color.progressCircle)
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                    .frame(maxHeight: 180)
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 20)
            }
            .clipShape(.rect(cornerRadius: 20))
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.progressCircle, lineWidth: 2)
                    .fill(Color.progressCircle.opacity(0.1))
            )
            .padding(.horizontal, 20)

            Spacer()

            /// MARK: Privacy links
            VStack {
                HStack(spacing: 30) {
                    Button {
                        openURL(URL(string: AppDefaults.TERMS_LINK)!)
                    } label: {
                        Text("Terms of use")
                            .foregroundStyle(.gray)
                            .font(.system(size: 14))
                    }
                    .foregroundStyle(.white)
                    
                    Button {
                        openURL(URL(string: AppDefaults.PRIVACY_LINK)!)
                    } label: {
                        Text("Privacy policy")
                            .foregroundStyle(.gray)
                            .font(.system(size: 14))
                    }
                    .foregroundStyle(.white)
                }
            }
            .padding(.vertical, 20)
            

            /// MARK: Subscribe button
            VStack {
                let label = store.getSubscribeButtonLabel(subscriptionId: selectedSubscriptionId)
                Button {
                    if label == "Manage subscription" {
                        Task {
                            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                do {
                                    try await AppStore.showManageSubscriptions(in: scene)
                                } catch {
                                    print("Error:(error)")
                                }
                            }
                            await store.restoreSubscription()
                            await store.loadSubScriptionInfo()
                            await MainActor.run {
                                store.verifySubscriptions()
                            }
                        }
                    } else {
                        Task {
                            let _ = await store.purchase(subscriptionId: selectedSubscriptionId)
                            await MainActor.run {
                                store.verifySubscriptions()
                                showPaywall = false
                            }
                            completion()
                        }
                    }
                } label: {
                    Text(label)
                        .fontWeight(.semibold)
                        .font(.system(size: 20))
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                        .background(label == "Manage subscription" ? .white : Color.progressCircle, in: Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, AppDefaults.bottomSafeArea)
        }
        .ignoresSafeArea()
        .frame(width: AppDefaults.screenWidth)
        .background(Color.gray5)
        .onChange(of: store.updatingSubscriptions) { prevValue, newValue in
            if prevValue && !newValue {
                message = store.getMessage(subscriptionId: selectedSubscriptionId)
                colorTrigger = self.store.currentSubscription != nil && selectedSubscriptionId == currentSubscriptionId
            }
        }
        .onAppear {
            if let subscription = self.store.currentSubscription {
                if subscription.renewProductId == subscription.id || subscription.renewProductId == "" {
                    self.selectedSubscriptionId = subscription.id
                } else {
                    if let renewSub = self.store.getSubscriptionBy(id: subscription.renewProductId) {
                        if renewSub.startDate ?? Date() > Date() {
                            self.selectedSubscriptionId = renewSub.id
                        } else {
                            self.selectedSubscriptionId = subscription.id
                        }
                    }
                }
            } else {
                self.selectedSubscriptionId = self.store.defaultSubscription?.id ?? ""
            }
            self.currentSubscriptionId = self.selectedSubscriptionId
            self.message = store.getMessage(subscriptionId: self.selectedSubscriptionId)
            self.colorTrigger = self.store.currentSubscription != nil

        }
    }
}
