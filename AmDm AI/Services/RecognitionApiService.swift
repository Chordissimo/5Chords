//
//  RecognitionApiService.swift
//  AmDm AI
//
//  Created by Marat Zainullin on 13/04/2024.
//

import Foundation
import Alamofire
import SwiftUI

class RecognitionApiService {
    @AppStorage("server_ip") private var server_ip: String = ""
    
    struct Response: Codable {
        var chords: [Chord]
    }
    
    private enum ServiceError: Error {
        case noResult
    }
    
    
    func recognizeAudio(
        url: URL,
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(url, withName: "file")
            },
            to: "http://" + server_ip + "/upload"
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
    
    func recognizeAudioFromYoutube(
        url: String,
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        let requestUrl = "http://" + server_ip + "/upload/youtube"
//          let requestUrl = "http://192.168.0.4:8000/upload/youtube" // Anton
//          let requestUrl = "http://192.168.10.8:8000/upload/youtube" //Marat
        AF.request(
            requestUrl,
            method: .post,
            parameters: ["url": url],
            encoding: JSONEncoding.default
        )
        .validate() // Optional: Validate the response (status code, content type, etc.)
        .responseDecodable(of: Response.self) { response in
            guard let result = response.value else {
                completion(.failure(response.error ?? ServiceError.noResult))
                return
            }
            
            completion(.success(result))
        }
    }
}
