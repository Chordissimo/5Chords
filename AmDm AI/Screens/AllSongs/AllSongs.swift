//
//  AnimatedCarousel.swift
//  AmDm AI
//
//  Created by Anton on 28/04/2024.
//
//
import SwiftUI
import AVFoundation

struct AllSongs: View {
    @ObservedObject var user = User()
    @State var showSettings = false
    @State var showUpload = false
    @State var youtubeViewPresented = false
    @State var recordPanelPresented = false
    @State var initialAnimationStep = 0
    @ObservedObject var songsList = SongsList()
    
    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                    
                    //Layer 1: song list + limited version label
                    VStack {
                        VStack {
                            SongsListView(songsList: songsList)
                        }
                        .frame(minHeight: proxy.size.height - 140)
                        
                        VStack {
                            if initialAnimationStep >= 1 {
                                LimitedVersionLabel(isLimitedVersion: user.subscriptionPlanId == 0)
                            }
                        }
                        .ignoresSafeArea()
                        .frame(height: 100)
                    }
                    
                    // Layer 2: Circles around the primary button
                    VStack {
                        if initialAnimationStep >= 1 {
                            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                                Circle()
                                    .frame(width: 121, height: 121)
                                    .foregroundColor(.customGray)
                                Ellipse()
                                    .frame(width: 121, height: 120)
                                    .foregroundColor(.customDarkGray)
                            }
                            .transition(.move(edge: .bottom))
                        }
                    }
                    
                    // Layer 3: Secondary buttons
                    VStack {
                        if initialAnimationStep >= 1 {
                            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                                HStack {
                                    HStack(spacing: 20) {
                                        NavigationSecondaryButton(imageName: "folder.circle.fill") {
                                            showUpload = true
                                        }
                                        .frame(width: 50, height: 50)
                                        NavigationSecondaryButton(imageName: "mic.circle.fill") {
                                            recordPanelPresented.toggle()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                withAnimation {
                                                    if !songsList.recordStarted {
                                                        songsList.startRecording()
                                                    }
                                                }
                                            }
                                        }
                                        .frame(width: 50, height: 50)
                                    }
                                    .padding(.top,20)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 20)  {
                                        NavigationSecondaryButton(imageName: "custom.sound.cloud") {
                                            print("custom.sound.cloud")
                                        }
                                        .frame(width: 50, height: 50)
                                        NavigationSecondaryButton(imageName: "custom.tuningfork") {
                                            print("custom.tuningfork")
                                        }
                                        .frame(width: 50, height: 50)
                                    }
                                    .padding(.top,20)
                                }
                            }
                            .padding(.horizontal,10)
                            .transition(.move(edge: .bottom))
                        }
                    }
                    .ignoresSafeArea()
                    .frame(height: 120)
                    
                    // Layer 4: Sliding recording panel with timer
                    VStack {
                        if recordPanelPresented {
                            Color.white.opacity(0.01)
                            VStack {
                                TimerView(timerState: $songsList.recordStarted, duration: $songsList.duration, songsList: songsList, songName: songsList.getNewSongName())
                                    .padding(.top, 20)
                            }
                            .transition(.move(edge: .bottom))
                            .ignoresSafeArea()
                        }
                    }
                    
                    // Layer 5: Primary button
                    VStack {
                        if initialAnimationStep == 2 {
                            NavigationPrimaryButton(imageName: "youtube.custom", recordStarted: $songsList.recordStarted) {
                                if recordPanelPresented {
                                    recordPanelPresented = false
                                    if songsList.recordStarted {
                                        songsList.stopRecording()
                                    }
                                } else {
                                    youtubeViewPresented = true
                                }
                            }
                            .padding(.bottom,20)
                            .transition(.scale(scale: 0, anchor: .center))
                        }
                    }.frame(height: 100)
                    
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            initialAnimationStep = 1
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            AudioServicesPlaySystemSound(SystemSoundID(1306)) //1104, 1306
                            withAnimation(.linear(duration: 0.1)) {
                                initialAnimationStep = 2
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        VStack {
                            Text("Pro Chords").font(.system(size: 32)).fontWeight(.semibold)
                        }
                    }
                }
                .toolbarBackground(Color.black, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark)
                .navigationBarItems(
                    trailing:
                        ActionButton(imageName: "slider.horizontal.3") {
                            showSettings = true
                        }.foregroundColor(.purple)
                )
                .fullScreenCover(isPresented: $user.accessDisallowed) {  Subscription(user: user)  }
                .fullScreenCover(isPresented: $showSettings) {
                    Settings(user: user, showSettings: $showSettings)
                }
                .fullScreenCover(isPresented: $youtubeViewPresented) {
                    YoutubeView(showWebView: $youtubeViewPresented, videoDidSelected: { resultUrl in
                        youtubeViewPresented = false
                        songsList.processYoutubeVideo(by: resultUrl)
                    })
                }
                .fileImporter(isPresented: $showUpload, allowedContentTypes: [.plainText]) { result in
                    switch result {
                    case .success(let file):
                        print(file.absoluteString)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}


struct NavigationPrimaryButton: View {
    var imageName: String
    @Binding var recordStarted: Bool
    var action: () -> Void
    
    var body: some View {
        GeometryReader { geometry  in
            let whiteCircleHeight = geometry.size.height
            let grayCircleHeight = whiteCircleHeight - 2
            let redCircleHeight = grayCircleHeight - 5
            let redSquareHeight = redCircleHeight * 0.5
            let redCircleHeightTapped = redSquareHeight - 5
            let imageHeight = redCircleHeight * 0.6
            let imageLogoWidth = redCircleHeight * 0.6
            
            ZStack {
                Circle()
                    .frame(width: whiteCircleHeight, height: whiteCircleHeight)
                    .foregroundStyle(Color.white)
                Circle()
                    .frame(width: grayCircleHeight, height: grayCircleHeight)
                    .foregroundStyle(Color.customDarkGray)
                Button {
                    withAnimation {
                        action()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .frame(width: recordStarted ? redCircleHeightTapped : redCircleHeight, height: recordStarted ? redCircleHeightTapped : redCircleHeight)
                            .foregroundStyle(Color.red)
                        
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: redSquareHeight, height: redSquareHeight)
                            .foregroundStyle(Color.red)
                        
                        if !recordStarted {
                            Image(imageName)
                                .resizable()
                                .foregroundColor(.white)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: imageLogoWidth, height: imageHeight)
                                .opacity(0.6)
                                .transition(.scale)
                        }
                    }
                }
            }
            .clipShape(Rectangle())
            .frame(width: geometry.size.width)
        }
    }
}


struct NavigationSecondaryButton: View {
    var imageName: String
    var action: () -> Void
    
    var body: some View {
        GeometryReader { geometry  in
            let whiteCircleHeight = geometry.size.height
            let grayCircleHeight = whiteCircleHeight - 2
            let redCircleHeight = grayCircleHeight - 5
            let imageHeight = redCircleHeight * 0.8
            let imageLogoWidth = redCircleHeight * 0.8
            
            ZStack {
                if imageName == "" {
                    Color.clear
                } else {
                    Circle()
                        .frame(width: whiteCircleHeight, height: whiteCircleHeight)
                        .foregroundStyle(Color.clear)
                    Circle()
                        .frame(width: grayCircleHeight, height: grayCircleHeight)
                        .foregroundStyle(Color.customDarkGray)
                    
                    Button {
                        withAnimation {
                            action()
                        }
                    } label: {
                        ZStack {
                            getSafeImage(named: imageName)
                                .resizable()
                                .foregroundColor(.white)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: imageLogoWidth, height: imageHeight)
                                .opacity(0.6)
                            
                        }
                    }
                }
            }
            .frame(width: geometry.size.width)
        }
    }
}


#Preview {
    AllSongs()
}
