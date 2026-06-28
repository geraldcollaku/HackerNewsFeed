//
//  NullStore.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 28.06.26.
//

import Foundation
import HackerNewsFeed

class NullStore: FeedStore & StoryStore {
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func insert(_ feed: [LocalFeedId], timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    func insert(_ story: LocalStory, completion: @escaping (InsertionResult) -> Void) {
        completion(.success(()))
    }
    
    func retrieve(for id: Int, completion: @escaping (StoryStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}
