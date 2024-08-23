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

class RecognitionApiService: RequestInterceptor {
    struct Response: Codable {
        var chords: [APIChord]
        var text: [AlignedText]?
        var tempo: Float
        var duration: Float
    }

    struct StatusResponse: Decodable {
        var found: Bool
        var completed: Bool
        var result: Result?
        
        enum CondingKeys: String, CodingKey {
            case found, completed, result
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
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {}
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        let response = request.task?.response as? HTTPURLResponse
        if let statusCode = response?.statusCode, statusCode == 202 {
            guard request.retryCount < AppDefaults.STATUS_CALL_RETRY_LIMIT else {
                completion(.doNotRetry)
                return
            }
            completion(.retryWithDelay(AppDefaults.STATUS_CALL_RETRY_INTERVAL))
        }
        completion(.doNotRetry)
    }
    
    func recognizeAudio(url: URL, songId: String, completion: @escaping ((Result<Response, Error>) -> Void)) {
        AuthService.getToken { token in
            AF.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(url, withName: "file")
                },
                to: AppDefaults.UPLOAD_ENDPOINT + "/" + songId,
                headers: [.authorization(bearerToken: token)]
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
    }
    
    func recognizeAudioFromYoutube(url: String, songId: String, completion: @escaping ((Result<Response, Error>) -> Void)) {
        AuthService.getToken { token in
            AF.request(
                AppDefaults.YOUTUBE_ENDPOINT + "/" + songId,
                method: .post,
                parameters: ["url": url],
                encoding: JSONEncoding.default,
                headers: [.authorization(bearerToken: token)]
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
    }

    func getUnfinished(songId: String, completion: @escaping ((Result<StatusResponse, Error>) -> Void)) {
        AuthService.getToken { token in
            AF.request(
                AppDefaults.STATUS_ENDPOINT + "/" + songId,
                method: .get,
                encoding: JSONEncoding.default,
                headers: [.authorization(bearerToken: token)]
            )
            .validate(statusCode: 200...200)
            .responseDecodable(of: StatusResponse.self) { response in
                guard let result = response.value else {
                    completion(.failure(response.error ?? ServiceError.noResult))
                    return
                }
                completion(.success(result))
            }
        }
    }

}
