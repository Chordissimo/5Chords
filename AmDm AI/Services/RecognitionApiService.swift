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
    @AppStorage("server_ip") private var server_ip: String = "64.226.99.83:80"
    private var cancellables = Set<AnyCancellable>()
    private var token: String = ""
    
    init() {
        AppCheckManager.shared.generateTokenAppCheck()
            .sink(
                receiveCompletion: { completion in
                    guard case let .failure(error) = completion else { return }
                    print(error)
                },
                receiveValue: { tokenString in
                    self.token = tokenString
                    // Continue building network request with the token and executing the request.
                    // See code snippet below
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
            to: "http://" + server_ip + "/upload"
//            ,headers: headers
//                to: "http://192.168.0.4:8000/upload" // Anton
//                to: "http://192.168.10.8:8000/upload" // Marat
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

        let requestUrl = "http://" + server_ip + "/upload/youtube"
//          let requestUrl = "http://192.168.0.4:8000/upload/youtube" // Anton
//          let requestUrl = "http://192.168.10.8:8000/upload/youtube" //Marat
        AF.request(
            requestUrl,
            method: .post,
            parameters: ["url": url],
            encoding: JSONEncoding.default
//            ,headers: headers
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
