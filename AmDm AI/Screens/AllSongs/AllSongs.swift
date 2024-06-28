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
    @AppStorage("isLimited") var isLimited: Bool = false
    @AppStorage("songCounter") var songCounter: Int = 0
    @EnvironmentObject var store: StorekitManager
    @State var showSettings = false
    @State var showUpload = false
    @State var showPaywall = false
    @State var youtubeViewPresented = false
    @State var recordPanelPresented = false
    @State var isTunerPresented = false
    @State var isLibraryPresented = false
    @State var initialAnimationStep = 0
    @ObservedObject var songsList = SongsList()
    let width: CGFloat
    
    init() {
        self.width = UIScreen.main.bounds.width
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            Color.gray5
            //Layer 1: song list + limited version label
            VStack {
                if isLimited {
                    VStack {
                        HStack {
                            Image(systemName: "crown.fill")
                                .resizable()
                                .foregroundColor(.crown)
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 20)
                            Text("Get the unlimited version")
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                                .font(.system(size: 18))
                        }
                    }
                    .frame(width: width, height: 50)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [.grad1, .grad2, .grad3]), startPoint: .leading, endPoint: .trailing)
                    )
                    .onTapGesture {
                        showPaywall = true
                    }
                }
                
                VStack {
                    SongList(songsList: songsList)
                }
                Color.customDarkGray
                    .ignoresSafeArea()
                    .frame(width: width, height: 100)
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
                                NavigationSecondaryButton(imageName: "folder.fill") {
                                    if isLimited && songCounter == 3 {
                                        showPaywall = true
                                    } else {
                                        showUpload = true
                                        songsList.showSearch = false
                                    }
                                }
                                .frame(width: 45, height: 45)
                                NavigationSecondaryButton(imageName: "mic.fill") {
                                    if isLimited && songCounter == 3 {
                                        showPaywall = true
                                    } else {
                                        recordPanelPresented.toggle()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            withAnimation {
                                                if !songsList.recordStarted {
                                                    songsList.showSearch = false
                                                    songsList.startRecording()
                                                }
                                            }
                                        }
                                    }
                                }
                                .frame(width: 45, height: 45)
                            }
                            .padding(.top,20)
                            
                            Spacer()
                            
                            HStack(spacing: 20)  {
                                NavigationSecondaryButton(imageName: "book.fill") {
                                    isLibraryPresented = true
                                }
                                .frame(width: 45, height: 45)
                                NavigationSecondaryButton(imageName: "custom.tuningfork.2") {
                                    isTunerPresented = true
                                }
                                .frame(width: 38, height: 38)
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
                        if isLimited && songCounter == 3 {
                            showPaywall = true
                        } else {
                            if recordPanelPresented {
                                recordPanelPresented = false
                                if songsList.recordStarted {
                                    songsList.stopRecording()
                                }
                            } else {
                                youtubeViewPresented = true
                            }
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
                    withAnimation(.linear(duration: 0.1)) {
                        initialAnimationStep = 2
                    }
                    let product = store.productConfig.first(where: { $0.isActive }) ?? nil
                    if product == nil {
                        showPaywall = true
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("COLLECTION")
                        .foregroundStyle(.secondaryText)
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                }
                .frame(height: 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color.gray10, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark)
        .navigationBarItems(
            leading:
                ActionButton(imageName: "custom.hexagon.fill") {
                    showSettings = true
                }
                .frame(height: 22)
                .foregroundColor(.white),
            trailing:
                ActionButton(imageName: "magnifyingglass") {
                    withAnimation {
                        songsList.showSearch.toggle()
                    }
                }.foregroundColor(.white)
        )
        .fullScreenCover(isPresented: $showPaywall) {  Paywall(showPaywall: $showPaywall)  }
        .fullScreenCover(isPresented: $showSettings) {
            Settings(showSettings: $showSettings) { showPaywall in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.showPaywall = showPaywall
                }
            }
        }
        .fullScreenCover(isPresented: $isTunerPresented) {
            TunerView(isTunerPresented: $isTunerPresented)
        }
        .fullScreenCover(isPresented: $isLibraryPresented) {
            ChordLibrary(isLibraryPresented: $isLibraryPresented)
        }
        .fullScreenCover(isPresented: $youtubeViewPresented) {
            YoutubeView(showWebView: $youtubeViewPresented, videoDidSelected: { resultUrl in
                youtubeViewPresented = false
                let ytService = YouTubeAPIService()
                ytService.getVideoData(videoUrl: resultUrl) { title, thumbnail in
                    songsList.processYoutubeVideo(by: resultUrl, title: title, thumbnailUrl: thumbnail)
                }
            })
        }
        .fileImporter(isPresented: $showUpload, allowedContentTypes: [.pdf, .mp3]) { result in
            switch result {
            case .success(let file):
                if file.startAccessingSecurityScopedResource() {
                    songsList.importFile(url: file)
                }
                file.stopAccessingSecurityScopedResource()
            case .failure(let error):
                print(error.localizedDescription)
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
