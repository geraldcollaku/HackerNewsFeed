//
//  FeedLoader.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 23.12.25.
//

enum LoadFeedResult {
    case success([String])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping () -> Void)
}
