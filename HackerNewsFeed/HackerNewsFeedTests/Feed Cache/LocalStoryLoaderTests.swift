//
//  LocalStoryLoaderTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

import XCTest
import HackerNewsFeed

protocol StoryStore {
    func retrieve(for id: Int)
}

final class LocalStoryLoader: StoryLoader {
    private let store: StoryStore
    
    init(store: StoryStore) {
        self.store = store
    }
    
    private struct Task: StoryLoaderTask {
        func cancel() {}
    }

    func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
        store.retrieve(for: id)
        return Task()
    }
}

class LocalStoryLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadStoryWithID_requestsStoryWithID() {
        let anyId = 0
        let (sut, store) = makeSUT()
        
        _ = sut.loadStory(with: anyId) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [anyId])
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalStoryLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalStoryLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private class FeedStoreSpy: StoryStore {
        private(set) var receivedMessages = [Int]()
        
        func retrieve(for id: Int) {
            receivedMessages.append(id)
        }
    }
}
