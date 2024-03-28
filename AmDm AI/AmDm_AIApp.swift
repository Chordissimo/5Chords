//
//  AmDm_AIApp.swift
//  AmDm AI
//
//  Created by Anton on 24/03/2024.
//

import SwiftUI
import SwiftData

@main
struct AmDm_AIApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AllSongs()
        }
        .modelContainer(sharedModelContainer)
    }
}
