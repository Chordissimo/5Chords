//
//  Settings.swift
//  AmDm AI
//
//  Created by Anton on 06/04/2024.
//

import SwiftUI

struct Settings: View {
    @Binding var showSettings: Bool
    var action: (Bool) -> Void
    @AppStorage("server_ip") private var server_ip: String = ""
    @Environment(\.openURL) var openURL
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                List {
                    Button {
                        showSettings = false
                        action(true)
                    } label: {
                        HStack {
                            Text("My subscription")
                            Spacer()
                            Image(systemName: "dollarsign.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 20)
                                .foregroundColor(.gray30)
                        }
                    }
                    .foregroundStyle(.white)
                                        
                    Button {
                        openURL(URL(string: "https://www.google.com")!)
                    } label: {
                        HStack {
                            Text("Privacy policy")
                            Spacer()
                            Image(systemName: "arrow.up.forward.square")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 18)
                                .foregroundColor(.gray30)
                        }
                    }
                    .foregroundStyle(.white)
                    
                    Button {
                        openURL(URL(string: "https://www.google.com")!)
                    } label: {
                        HStack {
                            Text("Terms of use")
                            Spacer()
                            Image(systemName: "arrow.up.forward.square")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 18)
                                .foregroundColor(.gray30)
                        }
                    }
                    .foregroundStyle(.white)
                    
                    NavigationLink {
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                Text("Server IP:")
                                    .fontWeight(.bold)
                            }
                            .padding(.leading, 20)
                            
                            TextField("192.168.0.5:8000", text: $server_ip)
                                .textFieldStyle(.roundedBorder)
                                .border(.customGray)
                                .foregroundStyle(Color.white)
                                .font(.system(size: 20))
                                .padding(.horizontal,20)
                            
                            VStack(alignment: .center) {
                                Button("Save") {
                                    showSettings = false
                                }
                                .foregroundColor(.black)
                                .buttonStyle(.borderedProminent)
                                .padding(.top, 20)
                            }
                            .frame(maxWidth: .infinity)
                            Spacer()
                        }
                        .padding(.top)
                    } label: {
                        Text("Server IP")
                    }

                }
                
            }
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ActionButton(imageName: "xmark.circle.fill") {
                        showSettings = false
                    }
                    .frame(height: 25)
                    .foregroundColor(.customGray)
                }
            }
        }
    }
}
