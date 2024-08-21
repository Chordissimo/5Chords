//
//  YouTubeAPIService.swift
//  AmDm AI
//
//  Created by Anton on 13/06/2024.
//

import Foundation
import Alamofire
//import Network

struct Response: Decodable {
    
    struct ContentDetails: Decodable {
        var duration: String

        enum CondingKeys: String, CodingKey {
            case duration
        }
    }

    struct Item: Decodable {
        var snippet: Snippet
        var contentDetails: ContentDetails

        enum CondingKeys: String, CodingKey {
            case snippet, contentDetails
        }
    }
    
    struct Snippet: Decodable {
        var title: String
        var thumbnails: Thumbnails
        var liveBroadcastContent: String

        enum CondingKeys: String, CodingKey {
            case title, thumbnails, liveBroadcastContent
        }
    }
    
    struct Thumbnails: Decodable {
        var `default`: ThumbnailURL

        enum CondingKeys: String, CodingKey {
            case `default`
        }
    }
    
    struct ThumbnailURL: Decodable {
        var url: String

        enum CondingKeys: String, CodingKey {
            case url
        }
    }
        
    var items: [Item]
    
    enum ItemsCondingKeys: String, CodingKey {
        case items
    }
}

struct PlistInfo : Decodable {
    let API_URL, API_KEY : String
    enum CondingKeys: String, CodingKey {
        case API_URL
        case API_KEY
    }
}

class YouTubeAPIService {
    func getVideoData(videoUrl: String, action: @escaping (String, String, Int) -> Void) {
        let appDefaults = AppDefaults()
        
        guard videoUrl != "" else { return }
        var videoId = ""

        if let urlComponent = URLComponents(string: videoUrl) {
            let queryItems = urlComponent.queryItems
            if let id = queryItems?.first(where: { $0.name == "v" })?.value {
                videoId = id
            }
        }

        guard videoId != "" else { return }

        guard appDefaults.GOOGLE_DATA_API_URL != "" && appDefaults.GOOGLE_DATA_API_KEY != "" else { return }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        AF.request(
            appDefaults.GOOGLE_DATA_API_URL,
            parameters: ["id": videoId, "part": "snippet,contentDetails", "key": appDefaults.GOOGLE_DATA_API_KEY]
        )
        .validate()
        .responseDecodable(of: Response.self, decoder: decoder) { response in
            switch response.result {
            case .success:
                if let resp = response.value {
                    if resp.items.count > 0 {
                        let duration = resp.items[0].snippet.liveBroadcastContent.lowercased() == "live" ? appDefaults.MAX_DURATION + 1 : resp.items[0].contentDetails.duration.getYoutubeDuration()
                        action(
                            resp.items[0].snippet.title,
                            resp.items[0].snippet.thumbnails.default.url,
                            duration
                        )
                    }
                }
                break
            case .failure(let error):
                print("YTService:",error.localizedDescription)
                return
            }
        }
    }
}
