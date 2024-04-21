//
//  AllSongsView.swift
//  AmDm AI
//
//  Created by Anton on 25/03/2024.
//

import SwiftUI

class RecognitionMode: ObservableObject {
    @Published var index: Int = 0
    @Published var stack: [modes] = [.youtube, .microphone, .upload]
    @Published var direction: Edge = .trailing
    @Published var currentLocation: CGFloat? = nil

    init(selected: modes) {
        self.index = selected.rawValue
    }
    
    enum dir: Int {
        case left = 0
        case right = 1
    }
    
    enum modes: Int {
        case youtube = 0
        case microphone = 1
        case upload = 2
    }
    
    func current() -> modes {
        return stack[index]
    }
    
    func swipeFromLeft() {
        index = index < stack.count - 1 ? index + 1 : 0
    }
    
    func swipeFromRight() {
        index = index == 0 ? stack.count - 1 : index - 1
    }
}

struct AllSongs: View {
    
    @Environment(\.modelContext) private var modelContext
    @State var user = User()
    @State var runsCount: Int = 0
    @State var showSettings = false
    @State var showUpload = false
    @State var youtubeViewPresented = false
    @ObservedObject var songsList = SongsList()
    @ObservedObject var recognitionMode = RecognitionMode(selected: .youtube)
    @State var initialAnimationStep = 0
    
    var body: some View {
        
        GeometryReader { geometry in
            let windowHeight = geometry.size.height
            NavigationStack {
                ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                    Color.black.ignoresSafeArea()
                    VStack {
                        VStack { // SongList
                            SongsListView(songsList: songsList)
                        }
                        VStack {
                            Color.clear
                        }
                        .ignoresSafeArea()
                        .frame(height: windowHeight * 0.1)
                    }
                    VStack { // recording panel with timer
                        if songsList.recordStarted {
                            Color.white.opacity(0.01)
                            VStack {
                                TimerView(timerState: $songsList.recordStarted, duration: $songsList.duration, songName: songsList.getNewSongName())
                                    .padding(.top, 20)
                                    .frame(height: windowHeight * 0.3)
                            }
                            .transition(.move(edge: .bottom))
                            .ignoresSafeArea()
                            .frame(height: windowHeight * 0.3)
                        }
                    }
                    
                    VStack { // record button
                        ZStack {
                            Color.customDarkGray
                            if initialAnimationStep == 1 {
                                AnimatedRecordButton()
                                    .transition(.scale(scale: 0.1))
                                    .padding(.vertical, 12)
                                
                            } else if initialAnimationStep == 2 {
                                HStack {
                                    Button {
                                        recognitionMode.direction = .trailing
                                        withAnimation {
                                            recognitionMode.swipeFromRight()
                                        }
                                    } label: {
                                        Image(systemName: "chevron.left")
                                            .resizable()
                                            .foregroundColor(.customGray)
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 15)
                                            .padding(.leading,15)
                                            .padding(.bottom, 25)
                                    }
                                    Spacer()
                                    if recognitionMode.current() == .microphone {
                                        RecordButton(recordStarted: $songsList.recordStarted) {
                                            if songsList.recordStarted {
                                                songsList.stopRecording()
                                            } else {
                                                songsList.startRecording()
                                            }
                                        }
                                        .padding(.vertical, 12)
                                        .transition(.push(from: recognitionMode.direction))
                                        
                                    } else if recognitionMode.current() == .youtube {
                                        YoutubeButton() {
                                            youtubeViewPresented = true
                                        }
                                        .padding(.vertical, 12)
                                        .transition(.push(from: recognitionMode.direction))

                                    } else {
                                        UploadButton() {
                                            showUpload = true
                                        }
                                        .padding(.vertical, 12)
                                        .transition(.push(from: recognitionMode.direction))

                                    }
                                    Spacer()
                                    Button {
                                        recognitionMode.direction = .leading
                                        withAnimation {
                                            recognitionMode.swipeFromLeft()
                                        }
                                    } label: {
                                        Image(systemName: "chevron.right")
                                            .resizable()
                                            .foregroundColor(.customGray)
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 15)
                                            .padding(.trailing,15)
                                            .padding(.bottom, 25)
                                    }

                                }
                            }
                        }
                    }
                    .ignoresSafeArea()
                    .frame(height: windowHeight * 0.1)
                    .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                        .onChanged({ value in
                            let newValue = value.location.x
                            if let prev = recognitionMode.currentLocation {
                                recognitionMode.direction = prev > newValue ? .trailing : .leading
                            }
                            recognitionMode.currentLocation = newValue
                        })
                        .onEnded { value in
                            withAnimation(.spring(.bouncy)) {
                                switch(value.translation.width, value.translation.height) {
                                case (...0, -30...30):  // left
                                    recognitionMode.swipeFromRight()
                                case (0..., -30...30): //right
                                    recognitionMode.swipeFromLeft()
                                default:  print("no clue")
                                }
                            }
                        }
                    )
                    
                    VStack { // limited version notice
                        LimitedVersionLabel(isLimitedVersion: user.subscriptionPlanId == 0)
                    }
                    .ignoresSafeArea()
                }
                .onAppear {
                    ScreenDimentions.maxWidth = geometry.size.width
                    ScreenDimentions.maxHeight = geometry.size.height
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        withAnimation(.snappy(extraBounce: 0.3)) {
                            initialAnimationStep = 1
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            initialAnimationStep = 2
                        }
                    }
                }
                .ignoresSafeArea(.keyboard)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        VStack {
                            Text("All songs")
                                .font(.system(size: 32))
                                .fontWeight(.semibold)
                        }
                    }
                }
//                .navigationTitle("All songs")
                .toolbarBackground(Color.black, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark)
                .navigationBarItems(
                    trailing:
                        ActionButton(systemImageName: "slider.horizontal.3") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                        .foregroundColor(.purple)
                )

                .fullScreenCover(isPresented: $user.accessDisallowed) {
                    Subscription(user: $user)
                }
                .fullScreenCover(isPresented: $showSettings) {
                    Settings(showSettings: $showSettings)
                        .animation(.easeInOut(duration: 2), value: showSettings)
                }
                .fullScreenCover(isPresented: $youtubeViewPresented) {
                    YoutubeView(showWebView: $youtubeViewPresented, videoDidSelected: { resultUrl in
                        youtubeViewPresented = false
                        songsList.processYoutubeVideo(by: resultUrl)
                    })
                    .animation(.easeInOut(duration: 2), value: youtubeViewPresented)
                }
                .fileImporter(
                    isPresented: $showUpload,
                    allowedContentTypes: [.plainText]
                ) { result in
                    switch result {
                    case .success(let file):
                        print(file.absoluteString)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}


#Preview {
    AllSongs()
}
