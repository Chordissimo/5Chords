//
//  OnboardingPage1.swift
//  AmDm AI
//
//  Created by Anton on 20/05/2024.
//

import SwiftUI

struct OnboardingPage1: View {
    @State var animationStage: Int = 0
    var body: some View {
        
        GeometryReader { geometry in
            let logoWidth = geometry.size.width * 0.24
            let logoHeight = geometry.size.height * 0.135
            
            if animationStage >= 8 {
                OnboardingPage2()
                    .transition(.push(from: .trailing))
            } else {
                
                ZStack {
                    Color.gray5
                    if animationStage >= 4 && animationStage < 8 {
                        Image("OnboardingPage1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .transition(.opacity)
                    }
                    VStack {
                        if animationStage > 1 && animationStage < 4 {
                            Image(animationStage == 3 ? "OnboardingPage2" : "OnboardingPage1")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .transition(.opacity)
                        } else if animationStage >= 4 && animationStage < 8 {
                            VStack {
                                Spacer()
                                Text("PICK YOUR")
                                    .fontWeight(.semibold)
                                    .fontWidth(.expanded)
                                    .font(.system(size: 30))
                                Text("FAVORITE SONG")
                                    .fontWeight(.semibold)
                                    .fontWidth(.expanded)
                                    .font(.system(size: 30))
                                    .foregroundStyle(.progressCircle)
                                    .glow()
                            }
                            .frame(height: 150)
                            .transition(.push(from: .top))
                            .padding(.bottom, 20)
                            
                        }
                        Spacer()
                    }
                    
                    if animationStage > 0 && animationStage < 8 {
                        VStack {
                            Image("logoOutlined")
                                .resizable()
                                .frame(width: logoWidth, height: logoHeight)
                                .aspectRatio(contentMode: .fill)
                                .transition(.opacity)
                            
                            if animationStage >= 4 {
                                VStack {
                                    Spacer().frame(height: 20)
                                    
                                    if animationStage >= 5 {
                                        VStack {
                                            HStack {
                                                Text("FROM")
                                                    .fontWeight(.semibold)
                                                    .fontWidth(.expanded)
                                                    .font(.system(size: 20))
                                                Text("YOUTUBE")
                                                    .fontWeight(.bold)
                                                    .fontWidth(.expanded)
                                                    .font(.system(size: 20))
                                                    .foregroundStyle(.red)
                                            }
                                        }
                                        .frame(width: 250, height: 50)
                                        .background(.progressCircle)
                                        .clipShape(
                                            .rect(
                                                topLeadingRadius: 0,
                                                bottomLeadingRadius: 20,
                                                bottomTrailingRadius: 0,
                                                topTrailingRadius: 20
                                            )
                                        )
                                        .transition(.scale(scale: 1.2))
                                        .padding(.bottom, 20)
                                    }
                                    
                                    if animationStage >= 6 {
                                        VStack {
                                            HStack {
                                                Text("RECORD")
                                                    .fontWeight(.bold)
                                                    .fontWidth(.expanded)
                                                    .font(.system(size: 20))
                                                    .foregroundStyle(.red)
                                                Text("AUDIO")
                                                    .fontWeight(.semibold)
                                                    .fontWidth(.expanded)
                                                    .font(.system(size: 20))
                                            }
                                        }
                                        .frame(width: 250, height: 50)
                                        .background(.progressCircle)
                                        .clipShape(
                                            .rect(
                                                topLeadingRadius: 0,
                                                bottomLeadingRadius: 20,
                                                bottomTrailingRadius: 0,
                                                topTrailingRadius: 20
                                            )
                                        )
                                        .transition(.scale(scale: 1.2))
                                        .padding(.bottom, 20)
                                    }
                                    
                                    if animationStage >= 7 {
                                        VStack {
                                            HStack {
                                                Text("UPLOAD")
                                                    .fontWeight(.bold)
                                                    .fontWidth(.expanded)
                                                    .font(.system(size: 20))
                                                    .foregroundStyle(.red)
                                                Text("AUDIO")
                                                    .fontWeight(.semibold)
                                                    .fontWidth(.expanded)
                                                    .font(.system(size: 20))
                                            }
                                        }
                                        .frame(width: 250, height: 50)
                                        .background(.progressCircle)
                                        .clipShape(
                                            .rect(
                                                topLeadingRadius: 0,
                                                bottomLeadingRadius: 20,
                                                bottomTrailingRadius: 0,
                                                topTrailingRadius: 20
                                            )
                                        )
                                        .transition(.scale(scale: 1.2))
                                        .padding(.bottom, 20)
                                        
                                        VStack {
//                                            FileFormatsView(width: geometry.size.width)
                                            Text("MP3, MPeg4, M4A, WAV\nand more")
                                                .lineLimit(2)
                                                .lineSpacing(10)
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.gray40)
                                                .fontWeight(.semibold)
                                                .fontWidth(.expanded)
                                                .frame(width: geometry.size.width)
                                        }
                                        .transition(.opacity)
                                    }
                                    
                                    Spacer()
                                }
                                .frame(height: logoHeight + 250)
                            }
                        }
                        .frame(height: logoHeight + 250)
                        
                        
                        VStack(spacing: 40) {
                            Spacer()
                            VStack {
                                if animationStage == 2 {
                                    VStack {
                                        HStack(spacing: 10) {
                                            Text("AI")
                                                .fontWeight(.semibold)
                                                .fontWidth(.expanded)
                                                .font(.system(size: 30))
                                            Text("CHORDS")
                                                .fontWeight(.semibold)
                                                .fontWidth(.expanded)
                                                .font(.system(size: 30))
                                                .foregroundStyle(.progressCircle)
                                                .glow()
                                        }
                                        Text("RECOGNITION")
                                            .fontWeight(.semibold)
                                            .fontWidth(.expanded)
                                            .font(.system(size: 30))
                                        
                                    }
                                    .transition(.push(from: .trailing))
                                } else if animationStage == 3 {
                                    VStack {
                                        HStack(spacing: 10) {
                                            Text("AI")
                                                .fontWeight(.semibold)
                                                .fontWidth(.expanded)
                                                .font(.system(size: 30))
                                            Text("LYRICS")
                                                .fontWeight(.semibold)
                                                .fontWidth(.expanded)
                                                .font(.system(size: 30))
                                                .foregroundStyle(.progressCircle)
                                                .glow()
                                        }
                                        Text("RECOGNITION")
                                            .fontWeight(.semibold)
                                            .fontWidth(.expanded)
                                            .font(.system(size: 30))
                                        
                                    }
                                    .transition(.push(from: .trailing))
                                }
                            }
                            if animationStage > 0 && animationStage < 3 {
                                VStack {
                                    Text("Instant Harmony:")
                                        .fontWeight(.semibold)
                                        .font(.system(size: 14))
                                        .foregroundStyle(.secondaryText)
                                    Text("AI Chord Detection at Your Fingertips")
                                        .fontWeight(.semibold)
                                        .font(.system(size: 14))
                                        .foregroundStyle(.secondaryText)
                                }
                            } else if animationStage == 3 {
                                VStack {
                                    Text("Unveil the Lyrics:")
                                        .fontWeight(.semibold)
                                        .font(.system(size: 16))
                                        .foregroundStyle(.secondaryText)
                                    Text("AI-Driven Lyrics Extraction")
                                        .fontWeight(.semibold)
                                        .font(.system(size: 16))
                                        .foregroundStyle(.secondaryText)
                                }
                            }
                            
                            VStack {
                                Button {
                                    if animationStage >= 2 {
                                        if animationStage == 3 {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                animationStage = 4
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    animationStage = 5
                                                }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    withAnimation(.easeInOut(duration: 0.3)) {
                                                        animationStage = 6
                                                    }
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                        withAnimation(.easeInOut(duration: 0.3)) {
                                                            animationStage = 7
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                animationStage += 1
                                            }
                                        }
                                    }
                                } label: {
                                    Text("Next")
                                        .fontWeight(.semibold)
                                        .font(.system(size: 20))
                                        .padding(20)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.black)
//                                        .frame(height: 50)
                                        .background(.progressCircle, in: Capsule())
                                        .padding(20)
                                        .padding(.bottom, geometry.safeAreaInsets.bottom)

//                                    ZStack {
//                                        Color.clear.frame(height: 150)
//                                        Circle()
//                                            .foregroundColor(.gray30)
//                                            .frame(height: 60)
//                                        Image(systemName: "arrow.right")
//                                            .resizable()
//                                            .frame(width: 25, height: 20)
//                                            .foregroundColor(.gray5)
//                                    }
                                }
                            }
                        }
                        .transition(.opacity)
                    }
                }
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        animationStage = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            animationStage = 2
                        }
                    }
                }
            }
        }
    }
}
