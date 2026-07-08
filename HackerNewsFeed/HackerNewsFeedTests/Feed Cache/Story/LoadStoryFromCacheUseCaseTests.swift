//
//  LoadStoryFromCacheUseCaseTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

import XCTest
import HackerNewsFeed

class LoadStoryFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadStoryWithID_requestsStoryWithID() {
        let anyId = 0
        let (sut, store) = makeSUT()
        
        _ = try? sut.loadStory(with: anyId)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(forId: anyId)])
    }
    
    func test_loadStoryWithID_deliversFailureOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failed(), when: {
            let retrievalError = anyNSError()
            store.completeRetrieval(with: retrievalError)
        })
    }
    
    func test_loadStoryWithID_deliversStoryOnNonEmptyCache() {
        let (sut, store) = makeSUT()
        let uniqueStory = uniqueStory()
        
        expect(sut, toCompleteWith: .success(uniqueStory.model), when: {
            store.completeRetrieval(with: uniqueStory.local)
        })
    }
    
    func test_loadStoryWithID_deliversFailureOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound(), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    func test_saveStory_requestStoryInsertion() {
        let (sut, store) = makeSUT()
        let story = uniqueStory()
        
        try? sut.save(story.model) 
        
        XCTAssertEqual(store.receivedMessages, [.insert(story: story.local)])
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalStoryLoader, store: FeedStoryStoreSpy) {
        let store = FeedStoryStoreSpy()
        let sut = LocalStoryLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func expect(_ sut: LocalStoryLoader,
                        toCompleteWith expectedResult: Result<Story, Error>,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        action()
        
        let receivedResult = Result {
            try sut.loadStory(with: anyId())
        }
        
        switch (receivedResult, expectedResult) {
        case let (.success(receivedStory), .success(expectedStory)):
            XCTAssertEqual(receivedStory, expectedStory, file: file, line: line)
            
        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            
        default:
            XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
    
    private func failed() -> Result<Story, Error> {
        .failure(LocalStoryLoader.LoadError.failed)
    }
    
    private func notFound() -> Result<Story, Error> {
        .failure(LocalStoryLoader.LoadError.notFound)
    }
    
    private func anyId() -> Int {
        0
    }
}
