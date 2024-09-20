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
    struct Response: Decodable {
        var chords: [APIChord]?
        var text: [AlignedText]?
        var tempo: Float?
        var duration: Float?
        var found: Bool?
        var completed: Bool?
        var result: Result?

        enum CondingKeys: String, CodingKey {
            case duration, text, chords, found, completed, result
        }
        
        struct Result: Decodable {
            var chords: [APIChord]?
            var text: [AlignedText]?
            var tempo: Float?
            var duration: Float?
            
            enum CondingKeys: String, CodingKey {
                case chords, text, tempo, duration
            }
        }
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
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
//        print("request intercepted:",urlRequest.url?.absoluteString as Any)
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
//        print("entered retry...")
        let response = request.task?.response as? HTTPURLResponse
        if let statusCode = response?.statusCode, statusCode == 202 {
            guard request.retryCount < AppDefaults.STATUS_CALL_RETRY_LIMIT else {
//                print("won't retry. retry count:",request.retryCount,"status:",response?.statusCode as Any)
                completion(.doNotRetry)
                return
            }
//            print("retry:", request.retryCount)
            completion(.retryWithDelay(AppDefaults.STATUS_CALL_RETRY_INTERVAL))
        }
    }
    
    func recognizeAudio(url: URL, songId: String, completion: @escaping ((Result<Response, Error>) -> Void)) {
        AF.sessionConfiguration.timeoutIntervalForRequest = 3000
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
            ) { urlRequest in
                urlRequest.timeoutInterval = 3000
            }
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
    
    func retrieveYoutubeFromDB(url: String, songId: String, completion: @escaping ((Result<Response, Error>, Int?) -> Void)) {
        AuthService.getToken { token in
            AF.request(
                AppDefaults.YOUTUBE_RETRIEVE_ENDPOINT + "/" + songId,
                method: .post,
                parameters: ["url": url],
                encoding: JSONEncoding.default,
                headers: [.authorization(bearerToken: token)]
            )
            .validate()
            .responseDecodable(of: Response.self) { response in
                guard let result = response.value else {
                    completion(.failure(response.error ?? ServiceError.noResult),response.response?.statusCode)
                    return
                }
                completion(.success(result),response.response?.statusCode)
            }
        }
    }

    func getUnfinished(songId: String, completion: @escaping ((Result<Response, Error>) -> Void)) {
        AuthService.getToken { token in
            AF.request(
                AppDefaults.STATUS_ENDPOINT + "/" + songId,
                method: .get,
                encoding: JSONEncoding.default,
                headers: [.authorization(bearerToken: token)],
                interceptor: self
            )
            .validate(statusCode: 200...200)
            .responseDecodable(of: Response.self) { response in
                guard let result = response.value else {
                    completion(.failure(response.error ?? ServiceError.noResult))
                    return
                }
                completion(.success(result))
            }
        }
    }

}
