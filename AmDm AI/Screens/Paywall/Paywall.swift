//
//  Paywall.swift
//  AmDm AI
//
//  Created by Anton on 21/05/2024.
//

import SwiftUI

struct Paywall: View {
    @AppStorage("isLimited") private var isLimited: Bool = false
    @EnvironmentObject var store: StorekitManager
    @State var selectedPlan = ""
    @Binding var showPaywall: Bool
    
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
                    
                    ForEach(self.store.productConfig, id: \.self.id) { product in
                        VStack(spacing: 10) {
                            if product.isPreferable {
                                HStack {
                                    Text(product.tagLine)
                                        .foregroundStyle(.progressCircle)
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                            }
                            HStack {
                                Text(product.title)
                                    .foregroundStyle(.white)
                                    .fontWeight(.bold)
                                Spacer()
                                if !product.isActive {
                                    Text(product.displayPrice)
                                        .foregroundStyle(.white)
                                        .fontWeight(.bold)
                                } else {
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 20)
                                        .foregroundStyle(.progressCircle)
                                }
                            }
                            if product.isPreferable {
                                HStack {
                                    Text(product.description)
                                        .foregroundStyle(.white)
                                        .opacity(0.3)
                                    Spacer()
                                }
                            }
                        }
                        .padding(20)
                        .background(selectedPlan == product.planId ? Color.clear : Color.paywallInactive)
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(selectedPlan == product.planId ? Color.progressCircle : Color.clear, lineWidth: 2)
                                .fill(selectedPlan == product.planId ? Color.progressCircle.opacity(0.1) : Color.clear)
                        )
                        .onTapGesture {
                            if !product.isActive {
                                selectedPlan = product.planId
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
                    Button {
                        Task {
                            let transaction = try await store.purchase(selectedPlan)
                            if transaction != nil {
                                isLimited = false
                                showPaywall = false
                            }
                        }
                    } label: {
                        let product = store.productConfig.first(where: { $0.isPreferable })
                        Text(selectedPlan == product?.planId ? "Start 7 days Free Trial" : "Subscribe")
                            .fontWeight(.semibold)
                            .font(.system(size: 20))
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.black)
                            .background(selectedPlan == product?.planId ? Color.progressCircle : .white, in: Capsule())
                    }
                    
                }
                .padding(20)
                .padding(.bottom, geometry.safeAreaInsets.bottom)
                
                VStack {
                    HStack {
                        Button {
                            isLimited = true
                            showPaywall = false
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18, height: 18)
                                .foregroundColor(.gray30)
                                .opacity(0.5)
                        }
                        Spacer()
                        Text("Choose your plan")
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                            .font(.system(size: 20))
                        Spacer()
                        Button {
                            print("")
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
                let product = store.productConfig.first(where: { $0.isPreferable })
                selectedPlan = product?.planId ?? ""
            }
        }
    }
}
