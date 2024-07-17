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

class RecognitionApiService {
    lazy var appDefaults = AppDefaults()
    private var cancellables = Set<AnyCancellable>()
    @Published var token: String = ""
    
    init() {
        AppCheckManager.shared.generateTokenAppCheck()
            .sink(
                receiveCompletion: { completion in
                    guard case let .failure(error) = completion else { return }
                    print(error)
                },
                receiveValue: { tokenString in
                    self.token = tokenString
                }
            )
            .store(in: &cancellables)
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
        let headers: HTTPHeaders = [.authorization(bearerToken: self.token)]
        
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(url, withName: "file")
            },
            to: appDefaults.UPLOAD_ENDPOINT,
            headers: headers
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
        let headers: HTTPHeaders = [.authorization(bearerToken: self.token)]

        let requestUrl = appDefaults.YOUTUBE_ENDPOINT
        AF.request(
            requestUrl,
            method: .post,
            parameters: ["url": url],
            encoding: JSONEncoding.default,
            headers: headers
        )
        .debugLog(url)
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

extension Request {
    public func debugLog(_ content: Any?) -> Self {
      #if DEBUG
        debugPrint(self, content as Any)
      #endif
      return self
   }
}
