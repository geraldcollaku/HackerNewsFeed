//
//  FeedStore.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 11.01.26.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (Error?) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    func insert(_ feed: [LocalFeedId], timestamp: Date, completion: @escaping InsertionCompletion)
    
    func retrieve(completion: @escaping RetrievalCompletion)
}
