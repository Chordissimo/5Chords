//
//  Paywall1.swift
//  AmDm AI
//
//  Created by Anton on 26/07/2024.
//

import SwiftUI
import StoreKit

struct Paywall: View  {
    var appDefaults = AppDefaults()
    @EnvironmentObject var store: ProductModel
    @AppStorage("isLimited") var isLimited: Bool = false
    @Binding var showPaywall: Bool
    @Environment(\.openURL) var openURL
    @State var selectedBillingPeriod: Subscription.BillingPeriod = .year
    @State var activeBillingPeriod: Subscription.BillingPeriod = .none
    var completion: () -> Void = {}
        
    var body: some View {
        VStack(spacing: 0) {
            /// MARK: Header
            VStack {
                HStack {
                    Button {
                        isLimited = store.activeSubscriptionId == ""
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
                        store.restoreSubscription()
                    } label: {
                        Text("Restore")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                            .font(.system(size: 20))
                    }
                }
                .padding(.top, appDefaults.topSafeArea)
                .padding(.horizontal, 20)
            }
            
            /// MARK: App name
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("PRO")
                        .fontWeight(.semibold)
                        .fontWidth(.expanded)
                        .font(.system(size: 38))
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
                    Button {
                        selectedBillingPeriod = .year
                    } label: {
                        Text("Yearly")
                            .fontWeight(.semibold)
                            .foregroundStyle(selectedBillingPeriod == .year ? Color.black : Color.white)
                            .frame(width: (appDefaults.screenWidth - 40) / 2, height: 40)
                    }
                    .background(selectedBillingPeriod == .year ? Color.white : Color.clear, in: Capsule())

                    Button {
                        selectedBillingPeriod = .month
                    } label: {
                        Text("Monthly")
                            .fontWeight(.semibold)
                            .foregroundStyle(selectedBillingPeriod == .month ? Color.black : Color.white)
                            .frame(width: (appDefaults.screenWidth - 40) / 2, height: 40)
                    }
                    .background(selectedBillingPeriod == .month ? Color.white : Color.clear, in: Capsule())
                }
                .background(Color.gray20)
                .clipShape(.rect(cornerRadius: 20))
                .padding(.horizontal, 20)
            }
            .frame(width: appDefaults.screenWidth)
            
            /// MARK: Price tag
            VStack {
                Text(selectedBillingPeriod == .month ? "$12.99 / mo" : "$8.33 / mo")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                Text(selectedBillingPeriod == .month ? "billed monthly" : "billed annually")
                    .fontWidth(.expanded)
                    .foregroundStyle(.secondaryText)
                    .font(.system(size: 11))
                Text(selectedBillingPeriod == activeBillingPeriod ? "You are currently subscribed to this" : "No commitement, cancel any time")
                    .foregroundStyle(selectedBillingPeriod == activeBillingPeriod ? .progressCircle : .white)
                    .font(.system(size: 14))
                    .fontWeight(selectedBillingPeriod == activeBillingPeriod ? .bold : .regular)
                    .padding(.top, 5)
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
                        openURL(URL(string: "https://www.aichords.pro/terms-of-use/")!)
                    } label: {
                        Text("Terms of use")
                            .foregroundStyle(.gray)
                            .font(.system(size: 14))
                    }
                    .foregroundStyle(.white)
                    
                    Button {
                        openURL(URL(string: "https://www.aichords.pro/privacy-policy/")!)
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
                let label = selectedBillingPeriod == activeBillingPeriod ? "Manage subscription" : (selectedBillingPeriod == .year ? "Start 7 days Free Trial" : "Subscribe")
                Button {
                    if selectedBillingPeriod == activeBillingPeriod {
                        Task {
                            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                do {
                                    try await AppStore.showManageSubscriptions(in: scene)
                                } catch {
                                    print("Error:(error)")
                                }
                            }
                        }
                    } else {
                        Task {
                            let status = await store.purchase(billingPeriod: selectedBillingPeriod)
                            showPaywall = !status
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
                        .background(selectedBillingPeriod == activeBillingPeriod ? .white : Color.progressCircle, in: Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, appDefaults.bottomSafeArea)
        }
        .ignoresSafeArea()
        .frame(width: appDefaults.screenWidth)
        .background(Color.gray5)
        .onAppear {
            self.activeBillingPeriod = store.getSubscriptionBy(id: store.activeSubscriptionId)?.billingPeriod ?? .none
            print(self.activeBillingPeriod,store.getSubscriptionBy(id: store.activeSubscriptionId) as Any)
        }
    }
}
