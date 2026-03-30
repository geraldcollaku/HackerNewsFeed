//
//  CacheStoryUseCaseTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

import XCTest
import HackerNewsFeed

class CacheStoryUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_saveStory_requestStoryInsertion() {
        let (sut, store) = makeSUT()
        let story = uniqueStory().local
        
        sut.save(story) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(story: story)])
    }
    
    func test_saveStory_failsOnStoreInsertionError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failed(), when: {
            let insertionError = anyNSError()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_saveStory_succeedsOnSuccessfulStoreInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_saveStory_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoryStoreSpy()
        var sut: LocalStoryLoader? = LocalStoryLoader(store: store)
        
        var received = [LocalStoryLoader.SaveResult]()
        sut?.save(uniqueStory().local) { received.append($0) }
        
        sut = nil
        
        store.completeInsertionSuccessfully()
        
        XCTAssertTrue(received.isEmpty, "Expected no received results after instance has been deallocated")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalStoryLoader, store: FeedStoryStoreSpy) {
        let store = FeedStoryStoreSpy()
        let sut = LocalStoryLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func failed() -> LocalStoryLoader.SaveResult {
        .failure(LocalStoryLoader.SaveError.failed)
    }
    
    private func expect(_ sut: LocalStoryLoader,
                        toCompleteWith expectedResult: LocalStoryLoader.SaveResult,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        sut.save(uniqueStory().local) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success): break
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
}

