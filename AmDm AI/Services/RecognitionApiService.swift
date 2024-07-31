//
//  RecognitionApiService.swift
//  AmDm AI
//
//  Created by Marat Zainullin on 13/04/2024.
//

import Foundation
import Alamofire
import SwiftUI
import Combine
import AuthenticationServices
import FirebaseAuth
import FirebaseCore

class RecognitionApiService {
    lazy var appDefaults = AppDefaults()
    var uid: String = ""
    
    init() {
        Task {
            do {
                let result = try await Auth.auth().signInAnonymously()
                self.uid = result.user.uid
            } catch {
                print("Auth error:",error)
            }
        }
    }
    
    struct Response: Codable {
        var chords: [APIChord]
        var text: [AlignedText]?
        var tempo: Float
        var duration: Float
    }
    
    private enum ServiceError: Error {
        case noResult
    }
    
    func recognizeAudio(url: URL, completion: @escaping ((Result<Response, Error>) -> Void)) {
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(url, withName: "file")
                multipartFormData.append(self.uid.data(using: String.Encoding.utf8)!, withName: "token")
            },
            to: appDefaults.UPLOAD_ENDPOINT
        )
        .validate()
        .responseDecodable(of: Response.self) { response in
            guard let result = response.value else {
                completion(.failure(response.error ?? ServiceError.noResult))
                return
            }
            
            completion(.success(result))
        }
    }
    
    func recognizeAudioFromYoutube(url: String, completion: @escaping ((Result<Response, Error>) -> Void)) {        
        let requestUrl = appDefaults.YOUTUBE_ENDPOINT
        AF.request(
            requestUrl,
            method: .post,
            parameters: ["url": url, "token": self.uid],
            encoding: JSONEncoding.default
        )
        .validate()
        .responseDecodable(of: Response.self) { response in
            guard let result = response.value else {
                completion(.failure(response.error ?? ServiceError.noResult))
                return
            }
            
            completion(.success(result))
        }
//        .debugLog()
    }
}

extension Request {
    public func debugLog() {
      #if DEBUG
        debugPrint("debugLog:",self.request?.httpBody as Any)
      #endif
   }
}
