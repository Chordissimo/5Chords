//
//  WFtest1.swift
//  AmDm AI
//
//  Created by Anton on 05/05/2024.
//

import SwiftUI
import AVKit

func readBuffer(url: URL) -> [CGFloat] {
    do {
        // let cur_url = Bundle.main.url(forResource: "splean", withExtension: "wav")!
        let file = try AVAudioFile(forReading: url)
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


    var body: some View {
        VStack(alignment: .leading)  {
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
                        .padding(.leading,4)
                }
            }
            
            VStack {
                Rectangle()
                    .frame(width: 1, height: index % 10 == 0 ? 10 : 7)
                    .foregroundColor(index % 5 == 0 && !isClear ? .white : .clear)
                    .padding(.leading,2)
            }
            
            Spacer()
            
            VStack {
                Rectangle()
                    .frame(width: 5, height: magnitude)
                    .foregroundColor(isClear ? .clear : .yellow)
                    .padding(.trailing, 0)
            }
        }
        .frame(minHeight: 100, maxHeight: 100)
    }
}


struct PlaybackTimelineView: View {
    private var bars: [CGFloat]
    @Binding var song: Song
    @ObservedObject var songsList: SongsList
    @ObservedObject var player: Player = Player()
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var currentItemID: Int?
    
    init(song: Binding<Song>, songsList: ObservedObject<SongsList>) {
        self._song = song
        self._songsList = songsList
        self.bars = readBuffer(url: song.url.wrappedValue)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                
                Button {
                    if player.isPlaying {
                        stopTimer()
                        player.stop()
                    } else {
                        if player.audioPlayer == nil {
                            player.setupAudio(url: song.url)
                        }
                        if player.currentTime != Double(currentItemID! / 2) {
                            player.seekAudio(to: Double(currentItemID! / 2))
                        }
                        startTimer()
                        player.play()
                    }
                } label: {
                    Text(player.isPlaying ? "Stop" : "Play")
                }
                
                ZStack {
                    Rectangle()
                        .foregroundColor(.red)
                        .frame(width: 3, height: 120)
                        .padding(.leading,5)
                        .zIndex(1.0)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: geometry.size.width / 2)

                            ForEach(0..<bars.count, id: \.self) { index in
                                BarView(magnitude: bars[index], index: index)
                                .id(index * 2)
                                
                                BarView(magnitude: bars[index], index: index, isClear: true)
                                .id(index * 2 + 1)
                            }
                            .frame(minHeight: 100, alignment: .bottom)
                        }
                        .scrollTargetLayout()
                    }
                    .scrollPosition(id: $currentItemID)
                    .onAppear() {
                        self.stopTimer()
                    }
                    .onReceive(timer) { time in
                        if player.currentTime == song.duration {
                            timer.upstream.connect().cancel()
                        } else {
                            proxy.scrollTo(player.currentTime * 2, anchor: .center)
                        }
                    }
                }
            }
        }
        
    }
    
    func stopTimer() {
        self.timer.upstream.connect().cancel()
    }
    
    func startTimer() {
        self.timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    }
}

//#Preview {
//    PlaybackTimelineView()
//}
