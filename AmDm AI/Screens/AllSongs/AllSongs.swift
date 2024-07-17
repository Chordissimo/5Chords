//
//  AnimatedCarousel.swift
//  AmDm AI
//
//  Created by Anton on 28/04/2024.
//
//
import SwiftUI
import AVFoundation
import Firebase

struct AllSongs: View {
    @AppStorage("isLimited") var isLimited: Bool = false
    @AppStorage("songCounter") var songCounter: Int = 0
//    @EnvironmentObject var store: StorekitManager
    @EnvironmentObject var store: MockStore
    @State var showSettings = false
    @State var showUpload = false
    @State var showPaywall = false
    @State var youtubeViewPresented = false
    @State var recordPanelPresented = false
    @State var isTunerPresented = false
    @State var isLibraryPresented = false
    @State var initialAnimationStep = 0
    @State var showRecognitionInProgressHint = false
//    @StateObject var songsList = SongsList()
    @EnvironmentObject var songsList: SongsList
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var showPermissionError = false
    let width: CGFloat
    let appDefaults = AppDefaults()
    
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
                
                //Bottom panel
                if !songsList.showSearch {
                    Rectangle()
                        .ignoresSafeArea()
                        .frame(width: width, height: 100)
                        .overlay(
                            Rectangle()
                                .frame(width: nil, height: 1)
                                .foregroundColor(Color.gray20),
                            alignment: .top
                                
                        )
                        .foregroundStyle(.customDarkGray)
                }
            }
            
            // Layer 2: Circles around the primary button
            VStack {
                if initialAnimationStep >= 1 && !songsList.showSearch {
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
                if initialAnimationStep >= 1 && !songsList.showSearch {
                    ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                        HStack {
                            HStack(spacing: 20) {
                                NavigationSecondaryButton(imageName: "folder.fill") {
                                    if isLimited && songCounter == appDefaults.LIMITED_NUMBER_OR_SONGS {
                                        showPaywall = true
                                    } else {
                                        if songsList.recognitionInProgress {
                                            if !showRecognitionInProgressHint {
                                                showRecognitionInProgressHint = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                                    showRecognitionInProgressHint = false
                                                }
                                            }
                                        } else {
                                            showUpload = true
                                            songsList.showSearch = false
                                        }
                                    }
                                }
                                .frame(width: 45, height: 45)
                                NavigationSecondaryButton(imageName: "mic.fill") {
                                    if isLimited && songCounter == appDefaults.LIMITED_NUMBER_OR_SONGS {
                                        showPaywall = true
                                    } else {
                                        if songsList.recognitionInProgress {
                                            if !showRecognitionInProgressHint {
                                                showRecognitionInProgressHint = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                                    showRecognitionInProgressHint = false
                                                }
                                            }
                                        } else {
                                            if !songsList.recordStarted {
                                                songsList.startRecording() { permissionGranted in
                                                    showPermissionError = !permissionGranted
                                                    if permissionGranted {
                                                        withAnimation {
                                                            recordPanelPresented = true
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                .frame(width: 45, height: 45)
                                .onChange(of: recordPanelPresented) { _, newValue in
                                    songsList.recordStarted = newValue
                                    if songsList.recordStarted {
                                        songsList.decibelChanges = [Float]()
                                        songsList.recognitionInProgress = true
                                        songsList.showSearch = false
                                        songsList.recordingService.startTimer()
                                    }
                                }
                                .onChange(of: songsList.recordingService.audioRecorder) { _, recorder in
                                    if recorder == nil {
                                        withAnimation {
                                            recordPanelPresented = false
                                        }
                                    }
                                }
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
                        TimerView(timerState: $songsList.recordStarted, duration: $songsList.duration, songsList: songsList, songName: songsList.getNewSongName(), recordPanelPresented: $recordPanelPresented) { isCancelled in
                            if isCancelled {
                                songsList.stopRecording(cancel: true)
                                songsList.recordStarted = false
                                songsList.recognitionInProgress = false
                                withAnimation {
                                    recordPanelPresented = false
                                }
                            }
                        }
                        .padding(.top, 20)
                    }
                    .transition(.move(edge: .bottom))
                    .ignoresSafeArea()
                }
            }
            
            // Layer 5: Primary button
            VStack {
                if initialAnimationStep == 2 && !songsList.showSearch {
                    NavigationPrimaryButton(imageName: "youtube.custom", recordStarted: $songsList.recordStarted, duration: $songsList.duration, durationLimit: (isLimited ? appDefaults.LIMITED_DURATION : appDefaults.MAX_DURATION)) {
                        if isLimited && songCounter == appDefaults.LIMITED_NUMBER_OR_SONGS {
                            showPaywall = true
                        } else {
                            if recordPanelPresented {
                                recordPanelPresented = false
                                if songsList.recordStarted {
                                    songsList.stopRecording()
                                }
                            } else {
                                if songsList.recognitionInProgress {
                                    if !showRecognitionInProgressHint {
                                        showRecognitionInProgressHint = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                            showRecognitionInProgressHint = false
                                        }
                                    }
                                } else {
                                    youtubeViewPresented = true
                                }
                            }
                        }
                    }
                    .padding(.bottom,20)
                    .transition(.scale(scale: 0, anchor: .center))
                }
            }
            .frame(height: 100)
            
            // Recognition in progress message
            if showRecognitionInProgressHint && songsList.recognitionInProgress {
                VStack(spacing: 0) {
                    Text("Extracting chords and lyrics.\nThis won't take long.")
                        .lineLimit(2)
                        .padding()
                        .frame(width: 300, height: 80)
                        .foregroundStyle(.gray5)
                        .fontWeight(.semibold)
                        .font(.system(size: 16))
                        .opacity(0.7)
                        .multilineTextAlignment(.center)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                        }
                    Triangle()
                        .fill(Color.white)
                        .frame(width: 30, height: 15)
                        .rotationEffect(Angle(degrees: 180.0))
                    Spacer()
                }
                .frame(height: 225)
            }
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
                self.youtubeViewPresented = false
                let ytService = YouTubeAPIService()
                ytService.getVideoData(videoUrl: resultUrl) { title, thumbnail, duration in
                    if duration == 0 {
                        self.showError = true
                        self.errorMessage = "We couldn't process the video you selected."
                    } else if duration > appDefaults.MAX_DURATION {
                        let duration = Int(appDefaults.MAX_DURATION / 60)
                        self.showError = true
                        self.errorMessage = "The selected video is too long. The maximum video duration we can hadnle is \(duration) minutes."
                    } else {
                        self.songsList.recognitionInProgress = true
                        self.songsList.processYoutubeVideo(by: resultUrl, title: title, thumbnailUrl: thumbnail)
                    }
                }
            })
        }
        .fileImporter(isPresented: $showUpload, allowedContentTypes: [.mp3, .mpeg4Audio, .wav, .aiff, .avi, .mpeg, .mpeg4Movie, .appleProtectedMPEG4Audio, .appleProtectedMPEG4Video]) { result in
            switch result {
            case .success(let file):
                if file.startAccessingSecurityScopedResource() {
                    do {
                        let attr = try FileManager.default.attributesOfItem(atPath: file.path(percentEncoded: false))
                        if let size = attr[FileAttributeKey.size] as? UInt64 {
                            if size == 0 {
                                self.showError = true
                                self.errorMessage = "No audio data found in the file you are trying to upload."
                            } else if size > (isLimited ? appDefaults.LIMITED_UPLOAD_FILE_SIZE : appDefaults.MAX_UPLOAD_FILE_SIZE) {
                                self.showError = true
                                let limitedSize = Int(appDefaults.LIMITED_UPLOAD_FILE_SIZE / 1024)
                                let maxSize = Int(appDefaults.MAX_UPLOAD_FILE_SIZE / 1024)
                                if isLimited {
                                    self.errorMessage = "The file you are trying to upload is too big. The maximum file size is \(limitedSize)Mb. Subscribe to upload up to \(maxSize)Mb."
                                } else {
                                    self.errorMessage = "The file you are trying to upload is too big. The maximum file size we can hadnle is \(maxSize)Mb."
                                }
                            } else {
                                self.songsList.recognitionInProgress = true
                                self.songsList.importFile(url: file)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
                file.stopAccessingSecurityScopedResource()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        .alert("Upload error", isPresented: $showError) {
            Button {
                showError = false
            } label: {
                Text("Ok")
            }
        } message: {
            Text(errorMessage)
        }
        .alert("Record permission denied", isPresented: $showPermissionError) {
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url)
                    }
                }
                showPermissionError = false
            } label: {
                Text("Open system settings")
            }
            Button {
                showPermissionError = false
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("You have denied the access to microphone. That means we are unable to capture and recognize chords and lyrics from audio input. If you wish to allow us to do so, please allow access for PROCHORDS app in the system settings.")
        }
    }
}


struct NavigationPrimaryButton: View {
    var imageName: String
    @Binding var recordStarted: Bool
    @Binding var duration: TimeInterval
    var durationLimit: Int
    var action: () -> Void
    @State var counter = -1
    @State var throb = false
    @AppStorage("isLimited") var isLimited: Bool = false
    
    var body: some View {
        GeometryReader { geometry  in
            let whiteCircleHeight = geometry.size.height
            let grayCircleHeight = whiteCircleHeight - 2
            let redCircleHeight = grayCircleHeight - 5
            let redSquareHeight = redCircleHeight * 0.5
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
//                    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
//                        AnalyticsParameterItemID: EventID.recognizeFromYoutube.rawValue,
//                        AnalyticsParameterItemName: "RecognizeFromYoutube"
//                    ])
                } label: {
                    ZStack {
                        if !recordStarted {
                            Circle()
                                .frame(width: redCircleHeight, height: redCircleHeight)
                                .foregroundStyle(Color.red)
                                .onAppear {
                                    throb = false
                                    counter = -1
                                }
                            Image(imageName)
                                .resizable()
                                .foregroundColor(.white)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: imageLogoWidth, height: imageHeight)
                                .opacity(0.6)
                                .transition(.scale)
                        } else {
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: redSquareHeight, height: redSquareHeight)
                                .foregroundStyle(counter == 0 ? Color.secondaryText : Color.red)
                                .opacity(counter > 0 ? 0.5 : 1)
                                .animation(.easeOut(duration: 0.5).repeatCount(18, autoreverses: true), value: throb)
                        }
                    }
                }
                .disabled(counter == 0)
//                .logEvent(screen: "AllSongs", event: .recognizeFromYoutube, title: "RecognizeFromYoutube")
            }
            .clipShape(Rectangle())
            .frame(width: geometry.size.width)
            .onChange(of: duration) { _, _ in
                if duration >= Double(durationLimit - 10) {
                    throb = true
                    counter = Int(Double(durationLimit) - duration)
                }
            }
            .overlay {
                if !isLimited && counter > 0 {
                    DurationLimitView(isLimited: isLimited)
                        .offset(x: 0, y: -320)
                }
            }
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
