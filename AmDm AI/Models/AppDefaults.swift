//
//  AppDefaults.swift
//  AmDm AI
//
//  Created by Anton on 11/07/2024.
//

import Foundation
import SwiftUI

public struct AppDefaults {
    public static var GOOGLE_DATA_API_KEY: String = "AIzaSyBETfbiYDupCbYGm1CfCbNVOyU_tYKfBTc"
    public static var GOOGLE_DATA_API_URL: String = "https://www.googleapis.com/youtube/v3/videos"
    public static var UPLOAD_ENDPOINT: String = "https://production.aichords.pro/upload"
    public static var YOUTUBE_ENDPOINT: String = "https://production.aichords.pro/youtube"
    public static var STATUS_ENDPOINT: String = "https://production.aichords.pro/status"
    public static var LIMITED_UPLOAD_FILE_SIZE: Int = 31457280
    public static var MAX_UPLOAD_FILE_SIZE: Int = 31457280
    public static var LIMITED_DURATION: Int = 60
    public static var MAX_DURATION: Int = 600
    public static var LIMITED_NUMBER_OF_SONGS: Int = 3
    public static var INTERVAL_START_ADJUSTMENT: Int = -1000
    public static var GUITAR_CHORDS_URL: String = "https://production.aichords.pro/chords/GuitarChords.json"
    public static var UKULELE_CHORDS_URL: String = "https://production.aichords.pro/chords/UkuleleChords.json"
    public static var STATUS_CALL_RETRY_LIMIT: Int = 12
    public static var STATUS_CALL_RETRY_INTERVAL: TimeInterval = 10.0
    
    public static var token: String {
        get { UserDefaults.standard.object(forKey: "token") as? String ?? "" }
        set(newValue) { UserDefaults.standard.set(newValue, forKey: "token") }
    }
    
    public static var tokenTimestamp: TimeInterval {
        get { UserDefaults.standard.object(forKey: "tokenTimestamo") as? TimeInterval ?? 0 }
        set(newValue) { UserDefaults.standard.set(newValue, forKey: "tokenTimestamo") }
    }
        
    public static var hideLyrics: Bool {
        get { UserDefaults.standard.object(forKey: "hideLyrics") as? Bool ?? false }
        set(newValue) { UserDefaults.standard.set(newValue, forKey: "hideLyrics") }
    }
    
    public static var isLimited: Bool {
        get { UserDefaults.standard.object(forKey: "isLimited") as? Bool ?? false }
        set(newValue) { UserDefaults.standard.set(newValue, forKey: "isLimited") }
    }
    
    public static var songCounter: Int {
        get { UserDefaults.standard.object(forKey: "songCounter") as? Int ?? 0 }
        set(newValue) { UserDefaults.standard.set(newValue, forKey: "songCounter") }
    }
    
    public static var showOnboarding: Bool {
        get { UserDefaults.standard.object(forKey: "showOnboarding") as? Bool ?? true }
        set(newValue) { UserDefaults.standard.set(newValue, forKey: "showOnboarding") }
    }
    
    public static var isPlaybackPanelMaximized: Bool {
        get { UserDefaults.standard.object(forKey: "isPlaybackPanelMaximized") as? Bool ?? true }
        set(newValue) { UserDefaults.standard.set(newValue, forKey: "isPlaybackPanelMaximized") }
    }
    
    public static var screenWidth: CGFloat {
        get { (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen.bounds.width ?? 0 }
    }
    
    public static var screenHeight: CGFloat {
        get { (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen.bounds.height ?? 0 }
    }
    
    public static var topSafeArea: CGFloat {
        get { (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top ?? 0 }
    }
    
    public static var bottomSafeArea: CGFloat {
        get { (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom ?? 0 }
    }
}
