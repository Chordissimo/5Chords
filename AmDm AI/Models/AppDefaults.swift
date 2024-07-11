//
//  AppDefaults.swift
//  AmDm AI
//
//  Created by Anton on 11/07/2024.
//

import Foundation

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
        
    init() {
        guard let path = Bundle.main.path(forResource: "AppDefaults-Info", ofType: "plist") else { return }

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
        } catch {
            print("AppDefaults:",error)
        }
    }
}
