//
//  UserDataModel.swift
//  AmDm AI
//
//  Created by Anton on 25/03/2024.
//

import Foundation
import SwiftData
import SwiftyChords

@Model
final class User {
    var registrationDate: Date?
    var subscriptionPlanId: Int = -1
    var accessDisallowed: Bool = true
    
    init() {}
    
    func selectPlan(registrationDate: Date, subscriptionPlanId: Int) {
        self.registrationDate = registrationDate
        self.subscriptionPlanId = subscriptionPlanId
        self.accessDisallowed = false
    }
    
}

struct SubscriptionPlan: Identifiable, Hashable {
    let id = UUID()
    let planId: Int
    let title: String
    let description: String
    let price: Float
}

struct MockData: Hashable {
    static let plans = [
        SubscriptionPlan(planId: 0, title: "Limited version", description: "Description", price: 0.0),
        SubscriptionPlan(planId: 1, title: "Plan A", description: "Description", price: 1.0),
        SubscriptionPlan(planId: 2, title: "Plan B", description: "Description", price: 4.99),
        SubscriptionPlan(planId: 3, title: "Plan C", description: "Description", price: 9.99)
    ]
}

// ----- AllSongsView ----

struct SongData: Identifiable, Hashable {
    let id = UUID()
    var created: Date = Date()
    var name: String = "Untitled song"
    var duration: TimeInterval = 0
    var playbackPosition = 0.0
    var isExpanded = false
    var chords = [Chord]()
}

struct Chord: Identifiable, Hashable {
    let id = UUID()
    var key: Chords.Key
    var suffix: Chords.Suffix
}

final class SongsList: ObservableObject {
    @Published var songs = [
        SongData(name: "Stareway to heaven", duration: TimeInterval(100), chords: [
            Chord(key: Chords.Key.a, suffix: Chords.Suffix.minor),
            Chord(key: Chords.Key.g, suffix: Chords.Suffix.major),
            Chord(key: Chords.Key.f, suffix: Chords.Suffix.major),
            Chord(key: Chords.Key.f, suffix: Chords.Suffix.majorSeven),
            Chord(key: Chords.Key.d, suffix: Chords.Suffix.susTwo),
            Chord(key: Chords.Key.d, suffix: Chords.Suffix.susFour),
            Chord(key: Chords.Key.c, suffix: Chords.Suffix.susTwo),
            Chord(key: Chords.Key.c, suffix: Chords.Suffix.susFour)]
        ),
        SongData(name: "Back in Black", duration: TimeInterval(60), chords: [
            Chord(key: Chords.Key.e, suffix: Chords.Suffix.major),
            Chord(key: Chords.Key.d, suffix: Chords.Suffix.major),
            Chord(key: Chords.Key.a, suffix: Chords.Suffix.major)]
        )
    ]
    
    init() {}
    
    func add(duration: TimeInterval, songName: String? = "") -> Void {
        let n = songName!.isEmpty ? getNewSongName() : songName!
        let song = SongData(name: n, duration: duration, isExpanded: true, chords: [
            Chord(key: Chords.Key.e, suffix: Chords.Suffix.major),
            Chord(key: Chords.Key.d, suffix: Chords.Suffix.major),
            Chord(key: Chords.Key.a, suffix: Chords.Suffix.major)]
        )
        self.songs.append(song)
        self.songs.sort { $0.created > $1.created }
        self.expand(index: 0)
    }
    
    func getNewSongName() -> String {
        let songs = self.songs.filter { s in
            s.name.contains("New recording")
        }
        if songs.isEmpty {
            return "New recording"
        } else {
            return "New recording " + String(songs.count)
        }
    }
    
    func del(index: Int) -> Void {
        self.songs.remove(at: index)
    }

    func del(song: SongData) -> Void {
        if let i = self.songs.firstIndex(of: song) {
            self.songs.remove(at: i)
        }
    }

    func expand(index: Int) {
        for i in songs.indices {
            songs[i].isExpanded = i == index
        }
    }

    func expand(song: SongData) {
        for i in songs.indices {
            songs[i].isExpanded = songs[i] == song
        }
    }

}
