//
//  FeedItemsMapper.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 26.12.25.
//

import Foundation

enum FeedItemsMapper {
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK, let items = try? JSONDecoder().decode([RemoteFeedItem].self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return items
    }
}
