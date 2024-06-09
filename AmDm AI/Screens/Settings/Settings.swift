//
//  Settings.swift
//  AmDm AI
//
//  Created by Anton on 06/04/2024.
//

import SwiftUI

struct Settings: View {
    @AppStorage("isLimited") private var isLimited: Bool = false
    @Binding var showSettings: Bool
    @AppStorage("server_ip") private var server_ip: String = ""
    @EnvironmentObject var store: StorekitManager
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack(alignment: .center) {
                    Spacer()
                    ActionButton(imageName: "xmark.circle.fill") {
                        showSettings = false
                    }
                    .frame(height: 25)
                    .foregroundColor(.customGray)
                }
                .padding(.trailing,20)
                
                Text("Settings")
                    .foregroundStyle(.white)
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text("Server IP:")
                            .fontWeight(.bold)
                    }
                    .padding(.leading, 20)
                    
                    TextField("", text: $server_ip)
                        .textFieldStyle(.roundedBorder)
                        .border(.customGray)
                        .foregroundStyle(Color.white)
                        .font(.system(size: 20))
                        .padding(.horizontal,20)
                }.padding(.top)
                
                VStack {
                    Button("Save") {
                        showSettings = false
                    }
                    .foregroundColor(.black)
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top, 20)
                
                VStack {
                    if let product = store.productConfig.first(where: { $0.isActive }) {
                        let upgradeOptions = store.productConfig.filter { $0.productPriority > product.productPriority }
                        let downgradeOptions = store.productConfig.filter { $0.productPriority < product.productPriority }
                        Text("My subscription:")
                            .foregroundStyle(.white)
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                        Text(product.title + " " + product.displayPrice)
                            .foregroundStyle(.white)
                            .font(.system(size: 20))
                        if upgradeOptions.count > 0 {
                            let upgradeTo = upgradeOptions.sorted { a, b in
                                a.productPriority > b.productPriority
                            }[0]
                            Button {
                                Task {
//                                    print(upgradeTo.planId)
                                    let transaction = try await store.purchase(upgradeTo.planId)
                                    if transaction != nil {
                                        isLimited = false
                                    }
                                }
                            } label: {
                                Text("Upgrade to " + upgradeTo.title + " " + upgradeTo.displayPrice + ", " + upgradeTo.billingPeriod)
                            }
                        }
                        if downgradeOptions.count > 0 {
                            let downgradeTo = downgradeOptions.sorted { a, b in
                                a.productPriority < b.productPriority
                            }[0]
                            Button {
                                Task {
                                    let transaction = try await store.purchase(downgradeTo.planId)
                                    if transaction != nil {
                                        isLimited = false
                                    }
                                }
                            } label: {
                                Text("Downgrade to " + downgradeTo.title + " " + downgradeTo.displayPrice + ", " + downgradeTo.billingPeriod)
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}
