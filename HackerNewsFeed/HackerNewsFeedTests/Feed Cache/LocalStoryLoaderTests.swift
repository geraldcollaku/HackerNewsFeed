//
//  LocalStoryLoaderTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

import XCTest
import HackerNewsFeed

protocol StoryStore {
    typealias Result = Swift.Result<Story, Error>
    
    func retrieve(for id: Int, completion: @escaping (Result) -> Void)
}

final class LocalStoryLoader: StoryLoader {
    private struct Task: StoryLoaderTask {
        func cancel() {}
    }
    
    enum Error: Swift.Error {
        case failed
    }
    
    private let store: StoryStore
    
    init(store: StoryStore) {
        self.store = store
    }
    
    func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
        store.retrieve(for: id) { result in
            completion(.failure(Error.failed))
        }
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
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(forId: anyId)])
    }
    
    func test_loadStoryWithID_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failed(), when: {
            let retrievalError = anyNSError()
            store.complete(with: retrievalError)
        })
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalStoryLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalStoryLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func failed() -> StoryLoader.Result {
        .failure(LocalStoryLoader.Error.failed)
    }
    
    private func expect(_ sut: LocalStoryLoader,
                        toCompleteWith expectedResult: StoryLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        _ = sut.loadStory(with: anyId()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedStory), .success(expectedStory)):
                XCTAssertEqual(receivedStory, expectedStory, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyId() -> Int {
        0
    }
    
    private class FeedStoreSpy: StoryStore {
        enum Message: Equatable {
            case retrieve(forId: Int)
        }
        
        private var completions = [(StoryStore.Result) -> Void]()
        private(set) var receivedMessages = [Message]()
        
        func retrieve(for id: Int, completion: @escaping (StoryStore.Result) -> Void) {
            receivedMessages.append(.retrieve(forId: id))
            completions.append(completion)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
    }
}
