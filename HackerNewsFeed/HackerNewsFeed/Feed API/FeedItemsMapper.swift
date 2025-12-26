//
//  FeedItemsMapper.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 26.12.25.
//

import Foundation

enum FeedItemsMapper {
    private typealias Item = Int
    
    private static var OK_200: Int { 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let items = try JSONDecoder().decode([Item].self, from: data)
        return items.map { FeedItem(id: $0) }
    }
}
