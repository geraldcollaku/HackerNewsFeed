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
    private var retrievalCompletions = [(StoryStore.RetrievalResult) -> Void]()
    private var insertionCompletions = [(StoryStore.InsertionResult) -> Void]()

    
    func insert(_ story: LocalStory, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(story: story))
        insertionCompletions.append(completion)
    }
    
    func retrieve(for id: Int, completion: @escaping (StoryStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(forId: id))
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with story: LocalStory, at index: Int = 0) {
        retrievalCompletions[index](.success(story))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](.success(.none))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
}
