//
//  FeedCommentsMapper.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 13.05.26.
//

import Foundation

enum FeedCommentsMapper {
    private struct Root: Codable {
        let ids: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard isOK(response), let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteCommentsLoader.Error.invalidData
        }
        
        return root.ids
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}
