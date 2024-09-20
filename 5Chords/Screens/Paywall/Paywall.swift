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
    @State var messageColorTrigger: Bool = false
    var completion: () -> Void = {}
    @State var disableSubscribe: Bool = true
//    @State var showManageSubs: Bool = false
    @State var showError: Bool = false
        
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                /// MARK: Header
                VStack {
                    HStack {
                        Button {
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
                                .font(.system( size: 18))
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                                .font(.system( size: 20))
                        }
                    }
                    .padding(.top, AppDefaults.topSafeArea + 10)
                    .padding(.horizontal, 20)
                }
                
                /// MARK: App name
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text("5")
                            .font(.custom("TitanOne", size: 60))
                            .foregroundStyle(.progressCircle)
                        Text("CHORDS")
                            .font(.custom(SOFIA_BOLD, size: 50))
                    }
                    Text("POWERED BY AI")
                        .font(.system( size: 10))
                        .fontWidth(.expanded)
                        .foregroundStyle(.secondaryText)
                }
                .padding(.vertical,40)
                
                /// MARK: Billing period selection
                VStack {
                    HStack(spacing: 0) {
                        ForEach(store.subscriptions, id: \.self) { subscription in
                            Button {
                                selectedSubscriptionId = subscription.id
                                message = self.store.getMessage(subscriptionId: selectedSubscriptionId)
                                messageColorTrigger = self.store.currentSubscription != nil && selectedSubscriptionId == currentSubscriptionId
                                
                            } label: {
                                Text(subscription.billingPeriodLabel)
                                    .font(.custom(SOFIA_SEMIBOLD, size: 18))
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
                    let monthlyPrice = subscription?.monthlyPrice ?? ""
                    let price = subscription?.fullPrice ?? ""
                    let billingPeriod = subscription == nil ? "" : (subscription!.billingPeriod == .year ? "billed annually" : "billed monthly")
                    let messageColor = store.getMessageColor(subscriptionId: selectedSubscriptionId)
                    
                    HStack(alignment: .bottom, spacing: 0) {
                        Text(price)
                            .font(.custom(SOFIA_BOLD, size: 24))
                        
                        Text(monthlyPrice != "" ? "\\" : "")
                            .font(.custom(SOFIA_BOLD, size: 24))
                            .foregroundStyle(.gray40)
                            .padding(.leading, monthlyPrice != "" ? 7 : 0)
                            .padding(.trailing, monthlyPrice != "" ? 4 : 0)

                        Text(monthlyPrice)
                            .font(.custom(SOFIA_BOLD, size: 20))
                            .foregroundStyle(.gray40)
                            .fontWeight(.semibold)
                            .padding(.bottom, 2)
                    }
                    .frame(height: 30)
                    
                    Text(billingPeriod)
                        .foregroundStyle(.secondaryText)
                        .font(.system( size: 14))
                    
                    Text(message)
                        .foregroundStyle(messageColor)
                        .font(.custom(messageColorTrigger ? SOFIA_BOLD : SOFIA, size: 14))
                        .padding(.top, 10)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 20)
                
                /// MARK: Product features
                VStack {
                    HStack {
                        Spacer()
                        Text("Premium features")
                            .font(.custom(SOFIA_BOLD, size: 16))
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
                                        .font(.system( size: 15))
                                    
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
                                .font(.system( size: 14))
                        }
                        .foregroundStyle(.white)
                        
                        Button {
                            openURL(URL(string: AppDefaults.PRIVACY_LINK)!)
                        } label: {
                            Text("Privacy policy")
                                .foregroundStyle(.gray)
                                .font(.system( size: 14))
                        }
                        .foregroundStyle(.white)
                    }
                }
                .padding(.vertical, 20)
                
                
                /// MARK: Subscribe button
                VStack {
                    let label = store.getSubscribeButtonLabel(subscriptionId: selectedSubscriptionId)
                    let buttonColor = store.getSubscribeButtonColor(subscriptionId: selectedSubscriptionId)
                    let manageSubs = store.showManageSubscriptions(subscriptionId: selectedSubscriptionId)
                    Button {
                        disableSubscribe = true
                        Task {
                            if manageSubs {
                                await store.openManageSubscription()
                            } else {
                                if await store.purchase(subscriptionId: selectedSubscriptionId) {
                                    await MainActor.run {
                                        if store.error == .none {
                                            self.currentSubscriptionId = store.currentSubscription?.id ?? ""
                                        }
                                    }
                                }
                            }
                            await MainActor.run { disableSubscribe = false }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                if store.error == .none {
                                    showPaywall = false
                                    completion()
                                }
                            }
                        }
                    } label: {
                        Text(label)
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.black)
                            .background(buttonColor, in: Capsule())
                    }
                    .disabled(disableSubscribe)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, AppDefaults.bottomSafeArea)
            }
            .ignoresSafeArea()
            .frame(width: AppDefaults.screenWidth)
            .background(Color.gray5)
            .onChange(of: store.updatingSubscriptions) { prevValue, newValue in
                if store.productInfoLoaded {
                    if prevValue && !newValue {
                        message = store.getMessage(subscriptionId: selectedSubscriptionId)
                        self.currentSubscriptionId = store.currentSubscription?.id ?? ""
                    }
                }
            }
            .onAppear {
                Task { await store.loadSubScriptionInfo() }
                if let subscription = self.store.currentSubscription {
                    self.currentSubscriptionId = subscription.id
                    if subscription.renewProductId == subscription.id {
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
                self.message = store.getMessage(subscriptionId: self.selectedSubscriptionId)
                self.messageColorTrigger = self.store.currentSubscription != nil
                disableSubscribe = false
            }
            .onChange(of: store.error) {
                if store.error != .none {
                    showError = true
                }
            }
            .alert("Something went wrong", isPresented: $showError) {
                Button {
                    store.error = .none
                    showError = false
                } label: {
                    Text("Ok")
                }
            } message: {
                Text(store.error.rawValue)
            }
            
            if store.updatingSubscriptions {
                Color.black.opacity(0.6)
                VStack {
                    ProgressView()
                        .scaleEffect(2, anchor: .center)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
        }
    }
}
