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
    var token: String = ""
    
    init() {
        Task {
            do {
                let result = try await Auth.auth().signInAnonymously()
                self.token = try await result.user.getIDToken()
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

    struct StatusResponse: Decodable {
        var completed: Bool
        var result: Result
        
        enum CondingKeys: String, CodingKey {
            case completed, result
        }
        
        struct Result: Decodable {
            var chords: [APIChord]
            var text: [AlignedText]?
            var tempo: Float
            var duration: Float
            
            enum CondingKeys: String, CodingKey {
                case chords, text, tempo, duration
            }
        }
    }
    
    private enum ServiceError: Error {
        case noResult
    }
    
    func recognizeAudio(url: URL, songId: String, completion: @escaping ((Result<Response, Error>) -> Void)) {
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(url, withName: "file")
            },
            to: appDefaults.UPLOAD_ENDPOINT + "/" + songId,
            headers: [.authorization(bearerToken: self.token)]
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
    
    func recognizeAudioFromYoutube(url: String, songId: String, completion: @escaping ((Result<Response, Error>) -> Void)) {
        AF.request(
            appDefaults.YOUTUBE_ENDPOINT + "/" + songId,
            method: .post,
            parameters: ["url": url],
            encoding: JSONEncoding.default,
            headers: [.authorization(bearerToken: self.token)]
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

    func getUnfinished(songId: String, completion: @escaping ((Result<StatusResponse, Error>) -> Void)) {
        AF.request(
            appDefaults.STATUS_ENDPOINT + "/" + songId,
            method: .post,
            parameters: ["task_id": songId],
            encoding: JSONEncoding.default,
            headers: [.authorization(bearerToken: self.token)]
        )
        .validate()
        .responseDecodable(of: StatusResponse.self) { response in
            guard let result = response.value else {
                completion(.failure(response.error ?? ServiceError.noResult))
                return
            }
            completion(.success(result))
        }
    }

}

extension Request {
    public func debugLog() {
      #if DEBUG
        debugPrint("debugLog:",self.request?.httpBody as Any)
      #endif
   }
}
