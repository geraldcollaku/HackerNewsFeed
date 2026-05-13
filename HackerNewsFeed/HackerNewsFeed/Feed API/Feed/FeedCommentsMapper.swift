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
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteCommentsLoader.Error.invalidData
        }
        
        return root.ids
    }
}
