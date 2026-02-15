//
//  FeedLoader.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 23.12.25.
//

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedId], Error>

    func load(completion: @escaping (Result) -> Void)
}
