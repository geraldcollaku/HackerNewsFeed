//
//  FeedCache.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 03.04.26.
//

public protocol FeedCache {
    func save(_ feed: [FeedId]) throws
}
