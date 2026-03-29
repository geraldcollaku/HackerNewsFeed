//
//  LocalStoryLoaderTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

import XCTest
import HackerNewsFeed

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
    
    func test_loadStoryWithID_doesNotDeliverResultAfterCancellingTask() {
        let (sut, store) = makeSUT()
        let local = uniqueStory().local
        
        var receivedResult = [StoryLoader.Result]()
        let task = sut.loadStory(with: anyId()) {
            receivedResult.append($0)
        }
        task.cancel()
        
        store.completeRetrieval(with: local)
        
        XCTAssertTrue(receivedResult.isEmpty, "Expected no received results after cancelling task")
    }
    
    func test_saveStory_requestStoryInsertion() {
        let (sut, store) = makeSUT()
        let story = uniqueStory().local
        
        sut.save(story) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(story: story)])
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
    
    private func failed() -> StoryLoader.Result {
        .failure(LocalStoryLoader.LoadError.failed)
    }
    
    private func notFound() -> StoryLoader.Result {
        .failure(LocalStoryLoader.LoadError.notFound)
    }
    
    private func uniqueStory() -> (model: Story, local: LocalStory) {
        let model = Story(
            id: 0,
            title: "a title",
            text: nil,
            author: "an author",
            score: 1,
            createdAt: Date(),
            totalComments: 0,
            comments: nil,
            type: "story",
            url: nil)
        let local = LocalStory(
            id: model.id,
            title: model.title,
            text: model.text,
            author: model.author,
            score: model.score,
            createdAt: model.createdAt,
            totalComments: model.totalComments,
            comments: model.comments,
            type: model.type,
            url: model.url)
        return (model, local)
    }
    
    private func anyId() -> Int {
        0
    }
}
