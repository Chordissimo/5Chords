//
//  Paywall.swift
//  AmDm AI
//
//  Created by Anton on 21/05/2024.
//

import SwiftUI

struct Paywall: View {
    @AppStorage("subscriptionPlan") private var subscriptionPlan: Int = -1
    @State var selectedPlan = 1
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
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text("Save 50%")
                                .foregroundStyle(.progressCircle)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        HStack {
                            Text("Yearly plan")
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                            Spacer()
                            Text("$10 / month")
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                            
                        }
                        HStack {
                            Text("12 month • $100")
                                .foregroundStyle(.white)
                                .opacity(0.3)
                            Spacer()
                        }
                    }
                    .padding(20)
                    .background(selectedPlan == 1 ? Color.clear : Color.paywallInactive)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(selectedPlan == 1 ? Color.progressCircle : Color.clear, lineWidth: 2)
                            .fill(selectedPlan == 1 ? Color.progressCircle.opacity(0.1) : Color.clear)
                    )
                    .onTapGesture {
                        selectedPlan = 1
                    }
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text("Monthly plan")
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                            Spacer()
                            Text("$10 / month")
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                            
                        }
                    }
                    .padding(20)
                    .background(selectedPlan == 2 ? Color.clear : Color.paywallInactive)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(selectedPlan == 2 ? Color.progressCircle : Color.clear, lineWidth: 2)
                            .fill(selectedPlan == 2 ? Color.progressCircle.opacity(0.1) : Color.clear)
                    )
                    .onTapGesture {
                        selectedPlan = 2
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
                        subscriptionPlan = selectedPlan
                        showPaywall = false
                    } label: {
                        Text(selectedPlan == 1 ? "Start 7 days Free Trial" : "Subscribe")
                            .fontWeight(.semibold)
                            .font(.system(size: 20))
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.black)
                            .background(selectedPlan == 1 ? Color.progressCircle : .white, in: Capsule())
                    }
                    
                }
                .padding(20)
                .padding(.bottom, geometry.safeAreaInsets.bottom)
                
                VStack {
                    HStack {
                        Button {
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
        }
    }
}
