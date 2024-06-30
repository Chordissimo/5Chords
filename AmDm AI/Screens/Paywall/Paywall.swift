//
//  Paywall.swift
//  AmDm AI
//
//  Created by Anton on 21/05/2024.
//

import SwiftUI
import StoreKit

struct Paywall: View {
    @AppStorage("isLimited") var isLimited: Bool = false
//    @EnvironmentObject var store: StorekitManager
    @EnvironmentObject var store: MockStore
    @State var selectedPlan = ""
    @Binding var showPaywall: Bool
    @State var monthlyPlan: ProductConfiguration?
    @State var yearlyPlan: ProductConfiguration?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.gray5
                VStack {
                    VStack {
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
                    .padding(.top, 100 + geometry.safeAreaInsets.top)
                    .padding(.bottom, 50)

                    VStack(spacing: 10) {
                        if yearlyPlan != nil {
                            ProductButton(product: yearlyPlan)
                                .background(selectedPlan == yearlyPlan!.planId ? Color.clear : Color.paywallInactive)
                                .cornerRadius(25)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(selectedPlan == yearlyPlan!.planId ? Color.progressCircle : Color.clear, lineWidth: 2)
                                        .fill(selectedPlan == yearlyPlan!.planId ? Color.progressCircle.opacity(0.1) : Color.clear)
                                )
                                .onTapGesture {
                                    if !yearlyPlan!.isActive {
                                        selectedPlan = yearlyPlan!.planId
                                    }
                                }
                        }
                        if monthlyPlan != nil {
                            ProductButton(product: monthlyPlan)
                                .background(selectedPlan == monthlyPlan!.planId ? Color.clear : Color.paywallInactive)
                                .cornerRadius(25)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(selectedPlan == monthlyPlan!.planId ? Color.progressCircle : Color.clear, lineWidth: 2)
                                        .fill(selectedPlan == monthlyPlan!.planId ? Color.progressCircle.opacity(0.1) : Color.clear)
                                )
                                .onTapGesture {
                                    if !monthlyPlan!.isActive && monthlyPlan!.startDate == nil {
                                        selectedPlan = monthlyPlan!.planId
                                    }
                                }
                        }
                    }

                    Spacer()
                    
                    VStack {
                        HStack(spacing: 30) {
                            Text("Terms of use")
                                .foregroundStyle(.gray)
                                .font(.system(size: 14))
                            Text("Privacy policy")
                                .foregroundStyle(.gray)
                                .font(.system(size: 14))
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 10)
                
                VStack {
                    Spacer()
                    
                    let label = yearlyPlan != nil && monthlyPlan != nil ?
                    (yearlyPlan!.isActive || monthlyPlan!.isActive ? "Subscribe" : (selectedPlan == yearlyPlan!.planId ? "Start 7 days Free Trial" : "Subscribe")) :
                    ""
                    let color = yearlyPlan != nil && monthlyPlan != nil ?
                    (yearlyPlan!.isActive || monthlyPlan!.isActive ? Color.white : (selectedPlan == yearlyPlan!.planId ? Color.progressCircle : Color.white)) :
                    Color.white
                    
                    let isDisabled = yearlyPlan != nil && monthlyPlan != nil ? (yearlyPlan!.isActive && monthlyPlan!.startDate != nil) : false

                    Button {
                        store.purchase(selectedPlan)
                        showPaywall = false
// ============================  Uncomment this before release ============
//                        Task {
//                            let transaction = try await store.purchase(selectedPlan)
//                            if transaction != nil {
//                                showPaywall = false
//                            }
//                        }
//=========================================================================
                    } label: {
                        
                        Text(label)
                            .fontWeight(.semibold)
                            .font(.system(size: 20))
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.black)
                            .background(isDisabled ? .gray20 : color, in: Capsule())
                    }
                    .disabled(isDisabled)
                    
                }
                .padding(20)
                .padding(.bottom, geometry.safeAreaInsets.bottom)
                
                VStack {
                    HStack {
                        let activeProduct = store.productConfig.first(where: { $0.isActive }) ?? nil
                        Button {
                            isLimited = activeProduct == nil
                            showPaywall = false
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18, height: 18)
                                .foregroundColor(activeProduct != nil ? .white : .gray30)
                                .opacity(0.5)
                        }
                        Spacer()
                        Text("Choose your plan")
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                            .font(.system(size: 20))
                        Spacer()
                        Button {
// ============================  Uncomment this before release ============
//                            Task {
//                                do {
//                                    try await AppStore.sync()
//                                    await store.updateCustomerProductStatus()
//                                } catch {
//                                    print(error)
//                                }
//                            }
//=========================================================================
                        } label: {
                            Text("Restore")
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.top, geometry.safeAreaInsets.top)
                    .padding(.horizontal, 10)
                    
                    Spacer()
                }
            }
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea()
            .onAppear {
                self.monthlyPlan = store.productConfig.first(where: { $0.billingPeriod == .month }) ?? nil
                self.yearlyPlan = store.productConfig.first(where: { $0.billingPeriod == .year }) ?? nil

                let plan = monthlyPlan != nil && yearlyPlan != nil ?
                (!yearlyPlan!.isActive ? yearlyPlan!.planId : (monthlyPlan!.startDate == nil ? monthlyPlan!.planId : "")) :
                ""
                
                selectedPlan = plan
            }
        }
    }
}

struct ProductButton: View {
    var product: ProductConfiguration?
    
    var body: some View {
        if product != nil {
            VStack(spacing: 10) {
                if product!.billingPeriod == .year {
                    HStack {
                        Text(product!.tagLine)
                            .font(.system(size: 18))
                            .foregroundStyle(.progressCircle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
                HStack {
                    Text(product!.title)
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                    Spacer()
                    if !product!.isActive {
                        if product!.startDate == nil {
                            Text(product!.displayPrice)
                                .font(.system(size: 18))
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                        } else {
                            Text("Activates on: " + product!.startDate!.formatted(date: .abbreviated , time: .omitted))
                                .font(.system(size: 14))
                                .lineLimit(2)
                                .foregroundStyle(.white)
                                .frame(width: 110)
                        }
                    } else {
                        Image(systemName: "checkmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                            .foregroundStyle(.progressCircle)
                    }
                }
                if product!.billingPeriod == .year {
                    HStack {
                        Text(product!.description)
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                            .opacity(0.3)
                        Spacer()
                    }
                }
            }
            .padding(20)
        }
    }
}
