//
//  FeedCache.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 03.04.26.
//

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feed: [FeedId], completion: @escaping (Result) -> Void)
}
