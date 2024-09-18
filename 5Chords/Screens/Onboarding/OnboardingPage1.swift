//
//  OnboardingPage1.swift
//  AmDm AI
//
//  Created by Anton on 20/05/2024.
//

import SwiftUI

struct OnboardingPage1: View {
    @State var animationStage: Int = 0
    var completion: () -> Void = {}
    
    var body: some View {
        
        GeometryReader { geometry in
            let logoHeight = geometry.size.height * 0.135
            
            if animationStage >= 8 {
                OnboardingPage2() {
                    completion()
                }
                .transition(.push(from: .trailing))
            } else {
                
                ZStack {
                    Color.gray5
                    if animationStage >= 4 && animationStage < 8 {
                        Image("files")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .transition(.opacity)
                    }
                    VStack {
                        if animationStage > 1 && animationStage < 4 {
                            Image(animationStage == 3 ? "man" : "girl")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .transition(.opacity)
                        } else if animationStage >= 4 && animationStage < 8 {
                            VStack {
                                Spacer()
                                Text("PICK YOUR")
                                    .font(.custom(SOFIA_BOLD, size: 38))

                                Text("FAVORITE SONG")
                                    .font(.custom(SOFIA_BOLD, size: 38))
                            }
                            .frame(height: 150)
                            .transition(.push(from: .top))
                            .padding(.bottom, 20)
                            
                        }
                        Spacer()
                    }
                    
                    if animationStage > 0 && animationStage < 8 {
                        VStack {
                            Image("logo3")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: logoHeight)
                                .transition(.opacity)
                            
                            if animationStage >= 4 {
                                VStack {
                                    Spacer().frame(height: 20)
                                    
                                    if animationStage >= 5 {
                                        VStack {
                                            HStack {
                                                Text("FROM")
                                                    .font(.custom(SOFIA_SEMIBOLD, size: 20))
                                                    .foregroundStyle(.gray10)

                                                Text("YOUTUBE™")
                                                    .font(.custom(SOFIA_SEMIBOLD, size: 20))
                                                    .foregroundStyle(.gray10)
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
                                                Text("RECORDED")
                                                    .font(.custom(SOFIA_SEMIBOLD, size: 20))
                                                    .foregroundStyle(.gray10)

                                                Text("AUDIO")
                                                    .font(.custom(SOFIA_SEMIBOLD, size: 20))
                                                    .foregroundStyle(.gray10)
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
                                                Text("UPLOADED")
                                                    .font(.custom(SOFIA_SEMIBOLD, size: 20))
                                                    .foregroundStyle(.gray10)

                                                Text("AUDIO")
                                                    .font(.custom(SOFIA_SEMIBOLD, size: 20))
                                                    .foregroundStyle(.gray10)
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
                                            Text("MP3, MPeg4, M4A, WAV\nand more")
                                                .font(.custom(SOFIA_BOLD, size: 18))
                                                .lineLimit(2)
                                                .lineSpacing(10)
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.gray40)
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
                                    VStack(spacing: 0) {
                                        HStack(spacing: 5) {
                                            Text("AI")
                                                .font(.custom(SOFIA_BOLD, size: 36))

                                            Text("CHORDS")
                                                .font(.custom(SOFIA_BOLD, size: 38))
                                                .foregroundStyle(.progressCircle)
                                        }
                                        Text("DETECTION")
                                            .font(.custom(SOFIA_BOLD, size: 38))
                                    }
                                    .transition(.push(from: .trailing))
                                } else if animationStage == 3 {
                                    VStack(spacing: 0) {
                                        HStack(spacing: 5) {
                                            Text("AI")
                                                .font(.custom(SOFIA_BOLD, size: 37))
                                            
                                            Text("LYRICS")
                                                .font(.custom(SOFIA_BOLD, size: 38))
                                                .foregroundStyle(.progressCircle)
                                        }
                                        Text("RECOGNITION")
                                            .fontWeight(.semibold)
                                            .fontWidth(.expanded)
                                            .font(.custom(SOFIA_BOLD, size: 38))
                                        
                                    }
                                    .transition(.push(from: .trailing))
                                }
                            }
                            if animationStage > 0 && animationStage < 3 {
                                VStack {
                                    Text("Instant Harmony:")
                                        .font(.custom(SOFIA, size: 14))
                                        .foregroundStyle(.secondaryText)
                                    Text("AI Chord Detection at Your Fingertips")
                                        .font(.custom(SOFIA, size: 14))
                                        .foregroundStyle(.secondaryText)
                                }
                            } else if animationStage == 3 {
                                VStack {
                                    Text("Unveil the Lyrics:")
                                        .font(.custom(SOFIA, size: 14))
                                        .foregroundStyle(.secondaryText)
                                    Text("AI-Driven Lyrics Extraction")
                                        .font(.custom(SOFIA, size: 14))
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
                                        .font(.custom(SOFIA_BOLD, size: 20))
                                        .padding(20)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.black)
                                        .background(.progressCircle, in: Capsule())
                                        .padding(20)
                                        .padding(.bottom, geometry.safeAreaInsets.bottom)
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
