//
//  FeedStore.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 11.01.26.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedId], timestamp: Date)

public protocol FeedStore {
    func deleteCachedFeed() throws
    func insert(_ feed: [LocalFeedId], timestamp: Date) throws
    func retrieve() throws -> CachedFeed?
}

