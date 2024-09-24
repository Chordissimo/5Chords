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
    @State var showPaywall = false
    @EnvironmentObject var store: ProductModel
    @State var showSettings = false
    @State var showUpload = false
    @State var youtubeViewPresented = false
    @State var recordPanelPresented = false
    @State var isTunerPresented = false
    @State var isLibraryPresented = false
    @State var initialAnimationStep = 0
    @State var showRecognitionInProgressHint = false
    @EnvironmentObject var songsList: SongsList
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var showPermissionError = false
    @State var showIsLimited: Bool = AppDefaults.isLimited
    @State var showBillingError: Bool = false
    @State var youtubeSearchUrl: String = ""
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            Color.gray5
            //Layer 1: song list + limited version label
            VStack {
                if showIsLimited {
                    VStack {
                        HStack {
                            Image("logo3")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 20)
                            Text("Upgrade to Premium")
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                                .font(.system( size: 18))
                        }
                    }
                    .frame(width: AppDefaults.screenWidth, height: 50)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [.grad1, .grad2, .grad3]), startPoint: .leading, endPoint: .trailing)
                    )
                    .onTapGesture {
                        showPaywall = true
                    }
                }
                
                VStack {
                    SongList(songsList: songsList, youtubeSearchUrl: $youtubeSearchUrl, youtubeViewPresented: $youtubeViewPresented)
                }
                
                //Bottom panel
                if !songsList.showSearch {
                    Rectangle()
                        .ignoresSafeArea()
                        .frame(width: AppDefaults.screenWidth, height: 100)
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
                                if UIDevice.current.userInterfaceIdiom == .pad {
                                    Spacer()
                                }
                                
                                NavigationSecondaryButton(imageName: "folder.fill") {
                                    if AppDefaults.isLimited && AppDefaults.songCounter == AppDefaults.LIMITED_NUMBER_OF_SONGS {
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

                                if UIDevice.current.userInterfaceIdiom == .pad {
                                    Spacer()
                                }
                                
                                NavigationSecondaryButton(imageName: "mic.fill") {
                                    if AppDefaults.isLimited && AppDefaults.songCounter == AppDefaults.LIMITED_NUMBER_OF_SONGS {
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
                                
                                if UIDevice.current.userInterfaceIdiom == .pad {
                                    Spacer()
                                }
                            }
                            .padding(.top,20)
                            
                            Spacer()
                                .apply {
                                    if UIDevice.current.userInterfaceIdiom == .pad {
                                        $0.frame(width: AppDefaults.screenWidth / 5)
                                    } else {
                                        $0
                                    }
                                }
                                
                            
                            HStack(spacing: 20)  {
                                
                                if UIDevice.current.userInterfaceIdiom == .pad {
                                    Spacer()
                                }
                                
                                NavigationSecondaryButton(imageName: "book.fill") {
                                    isLibraryPresented = true
                                }
                                .frame(width: 45, height: 45)
                                
                                if UIDevice.current.userInterfaceIdiom == .pad {
                                    Spacer()
                                }
                                
                                NavigationSecondaryButton(imageName: "custom.tuningfork.2") {
                                    isTunerPresented = true
                                }
                                .frame(width: 38, height: 38)
                                
                                if UIDevice.current.userInterfaceIdiom == .pad {
                                    Spacer()
                                }
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
                        .apply {
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                $0.frame(height: 400)
                            } else {
                                $0
                            }
                        }
                    }
                    .transition(.move(edge: .bottom))
                    .ignoresSafeArea()
                }
            }
            
            // Layer 5: Primary button
            VStack {
                if initialAnimationStep == 2 && !songsList.showSearch {
                    NavigationPrimaryButton(imageName: "youtube.custom", recordStarted: $songsList.recordStarted, duration: $songsList.duration, durationLimit: (AppDefaults.isLimited ? AppDefaults.LIMITED_DURATION : AppDefaults.MAX_DURATION)) {
                        if AppDefaults.isLimited && AppDefaults.songCounter == AppDefaults.LIMITED_NUMBER_OF_SONGS {
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
                        .font(.system( size: 16))
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
                    showBillingError = store.error == .billingIssue
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("My collection")
                        .foregroundStyle(.secondaryText)
                        .font(.custom(SOFIA_SEMIBOLD, size: 20))
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
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                        .foregroundColor(.white)
                },
            trailing:
                Button {
                    songsList.showSearch.toggle()
                } label: {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                        .foregroundColor(songsList.songs.count == 0 ? .gray40 : .white)
                }
                .disabled(songsList.songs.count == 0)
        )
        .fullScreenCover(isPresented: $showPaywall) {  
            Paywall(showPaywall: $showPaywall) {
                showIsLimited = AppDefaults.isLimited
                if !showIsLimited {
                    songsList.rebuildTimeframes()
                }
            }
        }
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
            YoutubeView(showWebView: $youtubeViewPresented, url: youtubeSearchUrl, videoDidSelected: { resultUrl in
                self.youtubeViewPresented = false
                self.youtubeSearchUrl = ""
                let ytService = YouTubeAPIService()
                ytService.getVideoData(videoUrl: resultUrl) { title, thumbnail, duration in
                    if duration == 0 {
                        self.showError = true
                        self.errorMessage = "We couldn't process the video you selected."
                    } else if duration > AppDefaults.MAX_DURATION {
                        let duration = Int(AppDefaults.MAX_DURATION / 60)
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
                            } else if size > (AppDefaults.isLimited ? AppDefaults.LIMITED_UPLOAD_FILE_SIZE : AppDefaults.MAX_UPLOAD_FILE_SIZE) {
                                self.showError = true
                                let limitedSize = Int(AppDefaults.LIMITED_UPLOAD_FILE_SIZE / 1024)
                                let maxSize = Int(AppDefaults.MAX_UPLOAD_FILE_SIZE / 1024)
                                if AppDefaults.isLimited {
                                    self.errorMessage = "The file you are trying to upload is too big. The maximum file size is \(limitedSize)Mb. Subscribe to upload up to \(maxSize)Mb."
                                } else {
                                    self.errorMessage = "The file you are trying to upload is too big. The maximum file size we can hadnle is \(maxSize)Mb."
                                }
                            } else {
                                if Player().setupAudio(url: file) {
                                    self.songsList.recognitionInProgress = true
                                    self.songsList.importFile(url: file)
                                } else {
                                    showError = true
                                    errorMessage = "The file is broken or it's format is not supported."
                                }
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
        .alert("Something went wrong", isPresented: $showBillingError) {
            Button {
                store.error = .none
                showBillingError = false
                Task {
                    await store.openManageSubscription()
                }
            } label: {
                Text("Manage subscriptions")
            }
            Button {
                store.error = .none
                showBillingError = false
            } label: {
                Text("Close")
            }
        } message: {
            Text(store.error.rawValue)
        }
    }
}
