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
    
    static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200, let data = try? JSONDecoder().decode([Item].self, from: data) else {
            return .failure(.invalidData)
        }
        
        let items = data.map { FeedItem(id: $0) }
        return .success(items)
    }
}
