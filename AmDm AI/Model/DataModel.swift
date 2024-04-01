//
//  UserDataModel.swift
//  AmDm AI
//
//  Created by Anton on 25/03/2024.
//

import Foundation
import SwiftData

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
    var duration: Int = 0
    var playbackPosition = 0.0
    var isExpanded = false
    var chords = [Chord]()
}

struct Chord: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var description: String
    //    let pictogram: ???
}

final class SongsList: ObservableObject {
    @Published var songs = [
        SongData(name: "Stareway to heaven", duration: 100, chords: [
            Chord(name: "Am", description: "A minor"),
            Chord(name: "G", description: "G major"),
            Chord(name: "F", description: "F major"),
            Chord(name: "Fmaj7", description: "F major 7"),
            Chord(name: "Dsus2", description: "D suspended 2"),
            Chord(name: "Dsus4", description: "D suspended 4"),
            Chord(name: "Csus2", description: "C suspended 2"),
            Chord(name: "Csus4", description: "C suspended 4")]
            ),
        SongData(name: "Back in Black", duration: 60, chords: [
            Chord(name: "E", description: "E minor"),
            Chord(name: "D", description: "D major"),
            Chord(name: "A", description: "A major")]
            )
        
    ]
    
    init() {}
    
    func add() -> Void {
        let song = SongData(name: "Back in Black", duration: 60, isExpanded: true, chords: [
            Chord(name: "E", description: "E minor"),
            Chord(name: "D", description: "D major"),
            Chord(name: "A", description: "A major")]
        )
        self.songs.append(song)
        self.songs.sort { $0.created > $1.created }
        self.expand(index: 0)
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
