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
    public typealias SaveResult = FeedCache.Result
    
    public func save(_ feed: [FeedId], completion: @escaping (SaveResult) -> Void) {
        completion(SaveResult {
            try store.deleteCachedFeed()
            try store.insert(feed.toLocal(), timestamp: currentDate())
        })
    }
}

extension LocalFeedLoader {
    public typealias LoadResult = Swift.Result<[FeedId], Error>

    public func load(completion: @escaping (LoadResult) -> Void) {
        completion(LoadResult {
            if let cache = try store.retrieve(), FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()) {
                return cache.feed.toModels()
            }
            return []
        })
    }
}

extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>
    
    private struct InvalidCache: Error {}
    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        completion(ValidationResult {
            do {
                if let cache = try store.retrieve(), !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()) {
                    throw InvalidCache()
                }
            } catch {
               try store.deleteCachedFeed()
            }
        })
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
