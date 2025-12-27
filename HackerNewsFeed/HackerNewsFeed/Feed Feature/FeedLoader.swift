//
//  FeedLoader.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 23.12.25.
//

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
