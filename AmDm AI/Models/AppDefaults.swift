//
//  AppDefaults.swift
//  AmDm AI
//
//  Created by Anton on 11/07/2024.
//

import Foundation
import SwiftUI

struct AppDefaults: Decodable {
    
    var GOOGLE_DATA_API_KEY: String = ""
    var GOOGLE_DATA_API_URL: String = ""
    var UPLOAD_ENDPOINT: String = ""
    var YOUTUBE_ENDPOINT: String = ""
    var LIMITED_UPLOAD_FILE_SIZE: Int = 0
    var MAX_UPLOAD_FILE_SIZE: Int = 0
    var LIMITED_DURATION: Int = 0
    var MAX_DURATION: Int = 0
    var LIMITED_NUMBER_OR_SONGS: Int = 0
    var INTERVAL_START_ADJUSTMENT: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case GOOGLE_DATA_API_KEY, GOOGLE_DATA_API_URL, UPLOAD_ENDPOINT, YOUTUBE_ENDPOINT, LIMITED_UPLOAD_FILE_SIZE, MAX_UPLOAD_FILE_SIZE, LIMITED_DURATION, MAX_DURATION, LIMITED_NUMBER_OR_SONGS, INTERVAL_START_ADJUSTMENT
    }
    
    var screenWidth: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    var topSafeArea: CGFloat = 0.0
    var bottomSafeArea: CGFloat = 0.0
        
    init() {
        guard let path = Bundle.main.path(forResource: "AppDefaults-Info", ofType: "plist") else { return }
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        if let window = windowScene?.windows.first {
            self.screenWidth = window.screen.bounds.width
            self.screenHeight = window.screen.bounds.height
            self.topSafeArea = window.safeAreaInsets.top
            self.bottomSafeArea = window.safeAreaInsets.bottom
        }

        do {
            let plistUrl = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: plistUrl)
            let plist = try PropertyListDecoder().decode(AppDefaults.self, from: data)
            self.GOOGLE_DATA_API_KEY = plist.GOOGLE_DATA_API_KEY
            self.GOOGLE_DATA_API_URL = plist.GOOGLE_DATA_API_URL
            self.UPLOAD_ENDPOINT = plist.UPLOAD_ENDPOINT
            self.YOUTUBE_ENDPOINT = plist.YOUTUBE_ENDPOINT
            self.LIMITED_UPLOAD_FILE_SIZE = plist.LIMITED_UPLOAD_FILE_SIZE
            self.MAX_UPLOAD_FILE_SIZE = plist.MAX_UPLOAD_FILE_SIZE
            self.LIMITED_DURATION = plist.LIMITED_DURATION
            self.MAX_DURATION = plist.MAX_DURATION
            self.LIMITED_NUMBER_OR_SONGS = plist.LIMITED_NUMBER_OR_SONGS
            self.INTERVAL_START_ADJUSTMENT = plist.INTERVAL_START_ADJUSTMENT
        } catch {
            print("AppDefaults:",error)
        }
    }
}
