//
//  CoreDataStoryStoreTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

import XCTest
import HackerNewsFeed

extension CoreDataFeedStore: @retroactive StoryStore {
    public func insert(_ story: LocalStory, completion: @escaping (StoryStore.InsertionResult) -> Void) {
        
    }
    public func retrieve(for id: Int, completion: @escaping (StoryStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}

class CoreDataStoryStoreTests: XCTestCase {
    
    func test_retrieveStory_deliversNotFoundWhenNotEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteWith: .success(.none))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: bundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: CoreDataFeedStore,
                        toCompleteWith expectedResult: StoryStore.RetrievalResult,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieve completion")
        sut.retrieve(for: anyId()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedStory), .success(expectedStory)):
                XCTAssertEqual(receivedStory, expectedStory, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got result \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyId() -> Int { 0 }
    
}
