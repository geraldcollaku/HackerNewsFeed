//
//  FeedStoreSpy.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

import HackerNewsFeed

class FeedStoryStoreSpy: StoryStore {
    enum Message: Equatable {
        case retrieve(forId: Int)
        case insert(story: LocalStory)
    }
    
    private(set) var receivedMessages = [Message]()
    private var retrievalResult: Result<LocalStory?, Error>?
    private var insertionResult: Result<Void, Error>?

    func insert(story: LocalStory) throws {
        receivedMessages.append(.insert(story: story))
        try insertionResult?.get()
    }
    
    func retrieve(for id: Int) throws -> LocalStory? {
        receivedMessages.append(.retrieve(forId: id))
        return try retrievalResult?.get()
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalResult = .failure(error)
    }
    
    func completeRetrieval(with story: LocalStory, at index: Int = 0) {
        retrievalResult = .success(story)
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalResult = .success(.none)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionResult = .success(())
    }
}
