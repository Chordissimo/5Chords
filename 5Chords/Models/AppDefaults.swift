//
//  AppDefaults.swift
//  AmDm AI
//
//  Created by Anton on 11/07/2024.
//

import FirebaseCore
import FirebaseStorage
import SwiftUI
import Alamofire
import SwiftyChords

let SOFIA = "SonfiaSans"
let SOFIA_SEMIBOLD = "SofiaSans-Regular_SemiBold"
let SOFIA_BOLD = "SofiaSans-Regular_Bold"
let SOFIA_EXTRABOLD = "SofiaSans-Regular_ExtraBold"
let SOFIA_BLACK = "SofiaSans-Regular_Black"
let TITAN = "TitanOne"

public struct AppDefaults {
    // --------- firebase defaults -----------------

    public static var GOOGLE_DATA_API_KEY: String {
        get { UserDefaults.standard.object(forKey: "GOOGLE_DATA_API_KEY") as? String ?? "AIzaSyBETfbiYDupCbYGm1CfCbNVOyU_tYKfBTc" }
    }

    public static var GOOGLE_DATA_API_URL: String {
        get { UserDefaults.standard.object(forKey: "GOOGLE_DATA_API_URL") as? String ?? "https://www.googleapis.com/youtube/v3/videos" }
    }

    public static var UPLOAD_ENDPOINT: String {
        get { UserDefaults.standard.object(forKey: "UPLOAD_ENDPOINT") as? String ?? "https://app.fivechords.com/api/recognize/upload" }
    }

    public static var YOUTUBE_RETRIEVE_ENDPOINT: String {
        get { UserDefaults.standard.object(forKey: "YOUTUBE_RETRIEVE_ENDPOINT") as? String ?? "https://app.fivechords.com/api/retrieve/youtube" }
    }

    public static var YOUTUBE_ENDPOINT: String {
        get { UserDefaults.standard.object(forKey: "YOUTUBE_ENDPOINT") as? String ?? "https://app.fivechords.com/api/recognize/youtube" }
    }

    public static var STATUS_ENDPOINT: String {
        get { UserDefaults.standard.object(forKey: "STATUS_ENDPOINT") as? String ?? "https://app.fivechords.com/api/retrieve/status" }
    }

    public static var PRIVACY_LINK: String {
        get { UserDefaults.standard.object(forKey: "PRIVACY_LINK") as? String ?? "https://fivechords.com/privacy-policy/" }
    }

    public static var TERMS_LINK: String {
        get { UserDefaults.standard.object(forKey: "TERMS_LINK") as? String ?? "https://fivechords.com/terms-of-use/" }
    }
    
    public static var LIMITED_UPLOAD_FILE_SIZE: Int {
        get { Int(UserDefaults.standard.object(forKey: "LIMITED_UPLOAD_FILE_SIZE") as? String ?? "31457280") ?? 31457280 }
    }

    public static var MAX_UPLOAD_FILE_SIZE: Int {
        get { Int(UserDefaults.standard.object(forKey: "MAX_UPLOAD_FILE_SIZE") as? String ?? "31457280") ?? 31457280 }
    }

    public static var LIMITED_DURATION: Int {
        get { Int(UserDefaults.standard.object(forKey: "LIMITED_DURATION") as? String ?? "60") ?? 60 }
    }
    
    public static var MAX_DURATION: Int {
        get { Int(UserDefaults.standard.object(forKey: "MAX_DURATION") as? String ?? "600") ?? 600 }
    }

    public static var LIMITED_NUMBER_OF_SONGS: Int {
        get { Int(UserDefaults.standard.object(forKey: "LIMITED_NUMBER_OF_SONGS") as? String ?? "3") ?? 3 }
    }

    public static var INTERVAL_START_ADJUSTMENT: Int {
        get { Int(UserDefaults.standard.object(forKey: "INTERVAL_START_ADJUSTMENT") as? String ?? "-1000") ?? -1000 }
    }

    public static var GUITAR_CHORDS_URL: String {
        get { UserDefaults.standard.object(forKey: "GUITAR_CHORDS_URL") as? String ?? "https://app.fivechords.com/chords/GuitarChords.json" }
    }

    public static var UKULELE_CHORDS_URL: String {
        get { UserDefaults.standard.object(forKey: "UKULELE_CHORDS_URL") as? String ?? "https://app.fivechords.com/chords/UkuleleChords.json" }
    }

    public static var STATUS_CALL_RETRY_LIMIT: Int {
        get { Int(UserDefaults.standard.object(forKey: "STATUS_CALL_RETRY_LIMIT") as? String ?? "10") ?? 10 }
    }

    public static var STATUS_CALL_RETRY_INTERVAL: TimeInterval {
        get { TimeInterval(UserDefaults.standard.object(forKey: "STATUS_CALL_RETRY_INTERVAL") as? String ?? "12") ?? 12 }
    }
    
// --------- local defaults -----------------
    public static var token: String {
        get { UserDefaults.standard.object(forKey: "token") as? String ?? "" }
        set(newValue) { UserDefaults.standard.set(newValue, forKey: "token") }
    }
    
    public static var tokenTimestamp: TimeInterval {
        get { UserDefaults.standard.object(forKey: "tokenTimestamp") as? TimeInterval ?? 0 }
        set(newValue) { UserDefaults.standard.set(newValue, forKey: "tokenTimestamp") }
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
    
    public static func loadDefaultsFromFirestore(completion: @escaping (Bool) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let fileRef = storageRef.child("/conf.json")
        
        fileRef.getData(maxSize: 1024 * 1024 * 10) { (data, error) in
            if let error = error {
                print("Error downloading file: \(error)")
            } else if let data = data {
                // Process the downloaded data (JSON file)
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    for item in json {
                        UserDefaults.standard.set(item.value, forKey: item.key)
                    }
                    completion(true)
                } else {
                    print("Error parsing JSON data")
                    completion(false)
                }
            }
        }
    }
    
    public static func loadChordsJSON(_ urlString: String, completion: @escaping () -> Void) {
        AF.request(
            urlString,
            method: .get,
            encoding: JSONEncoding.default
        )
        .validate()
        .responseDecodable(of: [ChordPosition].self) { response in
            guard let chordPositions = response.value else {
                completion()
                return
            }
            do {
                if chordPositions.count > 0 {
                    if chordPositions.count > 0 {
                        let json = String(data: try JSONEncoder().encode(chordPositions), encoding: .utf8)!
                        let data = Data(json.utf8)
                        do {
                            let filename = String(urlString.split(separator: "/").last ?? "")
                            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            let resourceUrl = documentsPath.appendingPathComponent(filename)
                            try data.write(to: resourceUrl, options: [.atomic, .completeFileProtection])
                        } catch {
                            print(error.localizedDescription)
                        }
                        completion()
                    }
                }
            } catch {
                #if DEBUG
                print("Couldn't parse data from \(urlString)\n\(error)")
                #endif
                completion()
            }
        }
    }
}
