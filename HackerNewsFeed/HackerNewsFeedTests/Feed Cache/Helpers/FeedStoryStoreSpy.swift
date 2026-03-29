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
        
        private var completions = [(StoryStore.RetrievalResult) -> Void]()
        private(set) var receivedMessages = [Message]()
        
        func insert(_ story: LocalStory, completion: @escaping (InsertionResult) -> Void) {
            receivedMessages.append(.insert(story: story))
        }
        
        func retrieve(for id: Int, completion: @escaping (StoryStore.RetrievalResult) -> Void) {
            receivedMessages.append(.retrieve(forId: id))
            completions.append(completion)
        }
        
        func completeRetrieval(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
        func completeRetrieval(with story: LocalStory, at index: Int = 0) {
            completions[index](.success(story))
        }
        
        func completeRetrievalWithEmptyCache(at index: Int = 0) {
            completions[index](.success(.none))
        }
    }
