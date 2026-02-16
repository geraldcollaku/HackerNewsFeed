//
//  FeedStoreSpy.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 16.01.26.
//

import HackerNewsFeed
import Foundation

class FeedStoreSpy: FeedStore {
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedId], Date)
        case retrieve
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    
    private var insertionCompletions = [InsertionCompletion]()
    
    private var retrievalCompletions = [RetrievalCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func insert(_ items: [LocalFeedId], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items, timestamp))
        
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](.success(.empty))
    }
    
    func completeRetrieval(with feed: [LocalFeedId], timestamp: Date, at index: Int = 0) {
        retrievalCompletions[index](.success(.found(feed: feed, timestamp: timestamp)))
    }
    
}
