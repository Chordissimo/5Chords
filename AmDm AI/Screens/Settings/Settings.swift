//
//  Settings.swift
//  AmDm AI
//
//  Created by Anton on 06/04/2024.
//

import SwiftUI

struct Settings: View {
    @ObservedObject var user: User
    @Binding var showSettings: Bool
    @AppStorage("server_ip") private var server_ip: String = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack(alignment: .center) {
                    Spacer()
                    ActionButton(systemImageName: "xmark.circle.fill") {
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
                
                Spacer()
            }
        }
    }
}

#Preview {
    @State var showSettings = true
    @ObservedObject var user = User()
    return Settings(user: user, showSettings: $showSettings)
}
