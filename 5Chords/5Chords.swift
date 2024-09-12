//
//  AmDm_AIApp.swift
//  AmDm AI
//
//  Created by Anton on 24/03/2024.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct AmDm_AIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
           
    var body: some Scene {
        WindowGroup {
            AppRoot()
        }
    }
}
