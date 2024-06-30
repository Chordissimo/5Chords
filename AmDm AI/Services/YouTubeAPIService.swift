//
//  YouTubeAPIService.swift
//  AmDm AI
//
//  Created by Anton on 13/06/2024.
//

import Foundation
import Alamofire
import Network

struct Response: Decodable {
    var title: String
    var thumbnail_url: String
    
    enum CondingKeys: String, CodingKey {
        case title, thumbnail_url
    }
    
}

class YouTubeAPIService {
    let YT_SEARCH_API_URL = "https://www.youtube.com/oembed?url="
    
    func getVideoData(videoUrl: String, action: @escaping (String, String) -> Void) {
        guard let url = URL(string: YT_SEARCH_API_URL) else { return}
        guard videoUrl != "" else { return }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        AF.request(
            url,
            parameters: ["url": videoUrl]
        )
        .validate()
        .responseDecodable(of: Response.self, decoder: decoder) { response in
            switch response.result {
            case .success:
                if let resp = response.value {
                    action(resp.title, resp.thumbnail_url)
                }
                break
            case .failure(let error):
                print("YTService: ",error.localizedDescription)
                return
            }
        }
    }
}
