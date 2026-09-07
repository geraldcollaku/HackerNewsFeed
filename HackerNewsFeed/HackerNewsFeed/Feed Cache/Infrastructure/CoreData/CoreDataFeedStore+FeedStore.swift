//
//  CoreDataFeedStore+FeedStore.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 30.03.26.
//

import CoreData

extension CoreDataFeedStore: FeedStore {
    
    public func retrieve() throws -> CachedFeed? {
        try perfomSync { context in
            Result {
                try ManagedCache.find(in: context).map {
                    CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedId], timestamp: Date) throws {
        try perfomSync { context in
            Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.news = ManagedNews.ids(from: feed, in: context)
                try context.save()
            }
        }
    }
    
    public func deleteCachedFeed() throws {
        try perfomSync { context in
            Result {
                try ManagedCache.deleteCache(in: context)
            }
        }
    }
}
