//
//  FeedItemsMapper.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 26.12.25.
//

import Foundation

typealias RemoteFeedItem = Int

enum FeedItemsMapper {
    private static var OK_200: Int { 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200, let items = try? JSONDecoder().decode([RemoteFeedItem].self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return items
    }
}
