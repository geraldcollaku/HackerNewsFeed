//
//  FeedStore.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 11.01.26.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedId], timestamp: Date)

public protocol FeedStore {
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    typealias RetrievalResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @available(*, deprecated)
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @available(*, deprecated)
    func insert(_ feed: [LocalFeedId], timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @available(*, deprecated)
    func retrieve(completion: @escaping RetrievalCompletion)
    
    func deleteCachedFeed() throws
    func insert(_ feed: [LocalFeedId], timestamp: Date) throws
    func retrieve() throws -> CachedFeed?
}

extension FeedStore {
    public func deleteCachedFeed() throws {
        let group = DispatchGroup()
        group.enter()
        deleteCachedFeed { _ in
            group.leave()
        }
        group.wait()
    }
    
    public func insert(_ feed: [LocalFeedId], timestamp: Date) throws {
        let group = DispatchGroup()
        group.enter()
        insert(feed, timestamp: timestamp) { _ in
            group.leave()
        }
        group.wait()
    }
    
    public func retrieve() throws -> CachedFeed? {
        let group = DispatchGroup()
        group.enter()
        var result: Result<CachedFeed?, Error>!
        retrieve {
            result = $0
            group.leave()
        }
        group.wait()
        return try result.get()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {}
    public func insert(_ feed: [LocalFeedId], timestamp: Date, completion: @escaping InsertionCompletion) {}
    public func retrieve(completion: @escaping RetrievalCompletion) {}
    
}
