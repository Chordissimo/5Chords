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
    struct Item: Decodable {
        struct Snippet: Decodable {
            var title: String = ""
        }
        var snippet: Snippet
    }
    
    var items: [Item]
//    
//    enum CodingKeys: String, CodingKey {
//        case kind, etag, regionCode, pageInfo, items
//    }
//    
//    init(from decoder: Decoder) throws {
//        print("0")
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        print("1")
//        print(container)
//        self.items = try container.decode([Video].self, forKey: .items)
//        print("2")
//        
//    }
}

class YouTubeAPIService {
//    @Published var videoTitle = Video()
    
    func getVideoData(videoId: String, action: @escaping (String) -> Void) {
        guard let url = URL(string: Constants.YT_SEARCH_API_URL) else { return}
        guard videoId != "" else { return }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        AF.request(
            url,
            parameters: ["part": "snippet", "type": "video", "q": videoId, "key": Constants.YT_API_KEY]
        )
        .validate()
        .responseDecodable(of: Response.self, decoder: decoder) { response in
            switch response.result {
            case .success:
                if let resp = response.value {
                    action(resp.items[0].snippet.title)
                }
                break
            case .failure(let error):
                print("YTService: ",error.localizedDescription)
                return
            }
        }
    }
}
