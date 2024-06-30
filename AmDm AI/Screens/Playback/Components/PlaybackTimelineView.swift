//
//  WFtest1.swift
//  AmDm AI
//
//  Created by Anton on 05/05/2024.
//

import SwiftUI
import AVKit

func readBuffer(url: URL) -> [CGFloat] {
    var _url: URL
    do {
        let isReachable = (try? url.checkResourceIsReachable()) ?? false
        if !isReachable {
            let filename = String(url.absoluteString.split(separator: "/").last ?? "")
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            _url = documentsPath.appendingPathComponent(filename)
        } else {
            _url = url
        }
        
        // let cur_url = Bundle.main.url(forResource: "splean", withExtension: "wav")!
        let file = try AVAudioFile(forReading: _url)
        if let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: file.fileFormat.sampleRate,
            channels: file.fileFormat.channelCount,
            interleaved: false
        ), let buf = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: AVAudioFrameCount(file.length)
        )
        {
            try file.read(into: buf)
            guard let floatChannelData = buf.floatChannelData else { return [CGFloat(0)]}
            let frameLength = Int(buf.frameLength)
            let samples = Array(UnsafeBufferPointer(start:floatChannelData[0], count:frameLength))
            
            let numberOfBarsInOneSecond = Int((Double(samples.count) / file.fileFormat.sampleRate) * 10)
            var result = [CGFloat]()
            let chunked = samples.chunked(into: samples.count / numberOfBarsInOneSecond)
            
            for i in 0..<chunked.count {
                let powerValues = chunked[i].map { $0 * $0 }
                let avgPowerPerBar = Float(powerValues.reduce(0,+)) / Float(chunked.count)
                let decibels = abs(30 / log10f(avgPowerPerBar))
                result.append(CGFloat(decibels > 40 ? decibels * 0.5 : decibels))
            }
            
            while result[0].magnitude == 0.0 {
                result.removeFirst()
            }
            
            while result[result.count - 1].magnitude == 0.0 {
                result.removeLast()
            }
            
            return result
        }
    } catch {
        print(error)
    }
    return [CGFloat(0)]
}


struct BarView: View {
    var magnitude: CGFloat
    var index: Int
    var isClear: Bool = false
    var showTimeScale: Bool = false
    
    
    var body: some View {
        VStack(alignment: .leading)  {
            if showTimeScale {
                VStack {
                    Rectangle()
                        .frame(width: 1, height: 1)
                        .foregroundColor(.clear)
                }
                .overlay {
                    if index % 10 == 0 && !isClear {
                        Text(formatTime(TimeInterval(index / 10), precision: TimePrecision.seconds))
                            .font(.system(size: 12))
                            .frame(width: 50)
                    }
                }
                
                VStack {
                    RoundedRectangle(cornerRadius: 3)
                        .frame(width: 1, height: index % 10 == 0 ? 10 : 7)
                        .foregroundColor(index % 5 == 0 && !isClear ? .white : .clear)
                }
            }
            
            Spacer()
                .frame(width: 5)
            
            VStack {
                Rectangle()
                    .fill(isClear ? Color.clear : Color.progressCircle)
                    .frame(width: 5, height: magnitude)
            }
        }
    }
}


struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: Int = 0
    
    static func reduce(value: inout Int, nextValue: () -> Int) {
        value = nextValue()
    }
    
    typealias Value = Int
    
}

struct ScrollViewOffsetModifier: ViewModifier {
    let coordinateSpace: String
    @Binding var offset: Int
    
    func body(content: Content) -> some View {
        ZStack {
            content
            GeometryReader { proxy in
                let x = abs(proxy.frame(in: .named(coordinateSpace)).minX)
                let currentItemID = Int(x / 5) * 5
                Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: currentItemID)
            }
        }
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
            offset = value
        }
    }
}

extension View {
    func readingScrollView(from coordinateSpace: String, into binding: Binding<Int>) -> some View {
        modifier(ScrollViewOffsetModifier(coordinateSpace: coordinateSpace, offset: binding))
    }
}


struct PlaybackTimelineView: View {
    var url: URL
    private var bars: [CGFloat]
    @ObservedObject var player: Player
    @State var currentItemID: Int = 0
    @State var offset: Int = 0
    
    init(song: Song, player: Player) {
        self.url = song.url
        self.player = player
        if song.songType == .youtube {
            self.bars = song.bars
        } else {
            self.bars = readBuffer(url: song.url)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            
            ZStack {
//                HStack {
//                    Rectangle()
//                        .foregroundColor(.white)
//                        .opacity(0.2)
//                        .frame(width: width / 2, height: height)
//                    //                    .padding(.leading,5)
//                        .zIndex(1.0)
//                    Spacer()
//                }
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: width / 2)
                                .id(-1)

                            ForEach(0..<bars.count, id: \.self) { index in
                                BarView(magnitude: bars[index], index: index)
                                    .id(index * 2 * 5)
                                
                                BarView(magnitude: bars[index], index: index, isClear: true)
                                    .id((index * 2 + 1) * 5)
                            }
                            .frame(minHeight: height - 20)
                            
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: width / 2)
                                .id((bars.count * 2 + 2) * 5)
                        }
                        .readingScrollView(from: "scroll", into: $offset)
                    }
                    .coordinateSpace(name: "scroll")
                    .gesture(DragGesture()
                        .onChanged { gesture in
                            if player.isPlaying {
                                player.stop()
                                player.isPlaying = false
                            }
                        }
                    )
                    .onTapGesture {
                        if player.isPlaying {
                            player.stop()
                            currentItemID = Int(player.currentTime * 100 / 5) * 5
                        } else {
                            if player.audioPlayer == nil {
                                player.setupAudio(url: url)
                            }
                            if offset != currentItemID {
                                player.seekAudio(to: TimeInterval(Float(offset) / 100))
                            }
                            player.play()
                        }
                    }
                    .onChange(of: player.currentTime) { oldValue, newValue in
                        if newValue < player.duration {
                            if Int(newValue * 100) % 5 == 0 {
                                proxy.scrollTo(Int(newValue * 100), anchor: .center)
                                currentItemID = Int(newValue * 100 / 5) * 5
                            }
                        }
                    }
                }
            }
        }
    }
}
