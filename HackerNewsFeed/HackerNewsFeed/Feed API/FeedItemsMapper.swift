//
//  FeedItemsMapper.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 26.12.25.
//

import Foundation

enum FeedItemsMapper {
    private struct Root: Codable {
        typealias RemoteFeedItem = Int
        let ids: [RemoteFeedItem]
        
        var items: [FeedId] {
            ids.map { FeedId(id: $0) }
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedId] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
