//
//  LocalFeedLoader.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 11.01.26.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
        
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader: FeedCache {
    public func save(_ feed: [FeedId]) throws {
        try store.deleteCachedFeed()
        try store.insert(feed.toLocal(), timestamp: currentDate())
    }
}

extension LocalFeedLoader {
    
    public func load() throws -> [FeedId] {
        if let cache = try store.retrieve(), FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()) {
            return cache.feed.toModels()
        }
        return []
    }
}

extension LocalFeedLoader {
    
    private struct InvalidCache: Error {}
    
    public func validateCache() throws {
        do {
            if let cache = try store.retrieve(), !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()) {
                throw InvalidCache()
            }
        } catch {
           try store.deleteCachedFeed()
        }
    }
}

private extension Array where Element == FeedId {
    func toLocal() -> [LocalFeedId] {
        map { LocalFeedId(id: $0.id) }
    }
}

private extension Array where Element == LocalFeedId {
    func toModels() -> [FeedId] {
        map { FeedId(id: $0.id) }
    }
}
