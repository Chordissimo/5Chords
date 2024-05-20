//
//  OnboardingPage3.swift
//  AmDm AI
//
//  Created by Anton on 20/05/2024.
//

import SwiftUI

struct OnboardingPage2: View {
    var body: some View {
        GeometryReader { geometry in
            let imageWidth = geometry.size.width * 0.6
            let imageHeight = geometry.size.height * 0.2
            let fileFormatWidth = geometry.size.width / 6
            ZStack {
                Color.gray5
                VStack {
                    VStack(spacing: 20) {
                        VStack {
                            Text("PICK YOUR")
                                .fontWeight(.semibold)
                                .fontWidth(.expanded)
                                .font(.system(size: 30))
                            Text("FAVORITE SONG")
                                .fontWeight(.semibold)
                                .fontWidth(.expanded)
                                .font(.system(size: 30))
                        }
                        VStack {
                            Text("Pick your favorite music video")
                                .fontWeight(.semibold)
                                .font(.system(size: 16))
                                .foregroundStyle(.secondaryText)
                            Text("from Youtube or just record it playing")
                                .fontWeight(.semibold)
                                .font(.system(size: 16))
                                .foregroundStyle(.secondaryText)
                            Text("and we'll extract chords and lyrics for you.")
                                .fontWeight(.semibold)
                                .font(.system(size: 16))
                                .foregroundStyle(.secondaryText)
                        }
                        VStack {
                            ZStack {
                                Image("OnboardingPage3_1")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Rectangle())
                                    .frame(width: imageWidth, height: imageHeight)
                                Text("FROM YOUTUBE")
                                    .frame(width: 250, height: 50)
                                    .background(.progressCircle)
                                    .fontWeight(.semibold)
                                    .fontWidth(.expanded)
                                    .font(.system(size: 20))
                            }
                            ZStack {
                                Image("OnboardingPage3_2")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Rectangle())
                                    .frame(width: imageWidth, height: imageHeight)
                                Text("VIA MICROPHONE")
                                    .frame(width: 250, height: 50)
                                    .background(.progressCircle)
                                    .fontWeight(.semibold)
                                    .fontWidth(.expanded)
                                    .font(.system(size: 20))
                            }
                        }
                        VStack {
                            Text("Upload an audio file from your device.")
                                .fontWeight(.semibold)
                                .font(.system(size: 16))
                                .foregroundStyle(.secondaryText)
                        }
                        VStack {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: geometry.size.width - fileFormatWidth + 4, height: 40)
                                    .border(.gray30, width: 1)
                                HStack(spacing: 0) {
                                    Text("MP3")
                                        .frame(width: fileFormatWidth, height: 40)
                                    Rectangle()
                                        .foregroundColor(.gray30)
                                        .frame(width: 1, height: 40)
                                    Text("MP4")
                                        .frame(width: fileFormatWidth, height: 40)
                                    Rectangle()
                                        .foregroundColor(.gray30)
                                        .frame(width: 1, height: 40)
                                    Text("M4A")
                                        .frame(width: fileFormatWidth, height: 40)
                                    Rectangle()
                                        .foregroundColor(.gray30)
                                        .frame(width: 1, height: 40)
                                    Text("WAV")
                                        .frame(width: fileFormatWidth, height: 40)
                                    Rectangle()
                                        .foregroundColor(.gray30)
                                        .frame(width: 1, height: 40)
                                    Text("AAC")
                                        .frame(width: fileFormatWidth, height: 40)
                                    Rectangle()
                                        .foregroundColor(.gray30)
                                        .frame(width: 1, height: 40)
                                }
                            }
                        }
                        VStack {
                            ZStack {
                                Color.clear.frame(height: 150)
                                Circle()
                                    .foregroundColor(.gray30)
                                    .frame(height: 60)
                                Image(systemName: "arrow.right")
                                    .resizable()
                                    .frame(width: 25, height: 20)
                                    .foregroundColor(.gray5)
                            }
                        }
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    OnboardingPage2()
}
