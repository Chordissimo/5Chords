//
//  RecognitionApiService.swift
//  AmDm AI
//
//  Created by Marat Zainullin on 13/04/2024.
//

import Foundation
import Alamofire


class RecognitionApiService {
    
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
        
        AF
            .upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(url, withName: "file")
                },
                to: "http://192.168.0.4:8000/upload"
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
        url: URL,
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        
    }
}
