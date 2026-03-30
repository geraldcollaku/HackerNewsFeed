//
//  CoreDataStoryStoreTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

import XCTest
import HackerNewsFeed

class CoreDataStoryStoreTests: XCTestCase {
    
    func test_retrieveStory_deliversNotFoundWhenNotEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteWith: notFound(), for: anyId())
    }
    
    func test_retrieveStory_deliversNotFoundWhenStoredStoryDoesNotMatch() {
        let sut = makeSUT()
        let id = 0
        let story = localStory(with: id)
        let nonMatchingId = anyId(1)
        
        insert(story, for: id, into: sut)
        
        expect(sut, toCompleteWith: notFound(), for: nonMatchingId)
    }
    
    func test_retrieveStory_deliversFoundStoryWhenThereIsAStoreStoryMatchingID() {
        let sut = makeSUT()
        let matchingId = 0
        let story = localStory(with: matchingId)
        
        insert(story, for: matchingId, into: sut)
        
        expect(sut, toCompleteWith: found(story), for: matchingId)
    }
    
    func test_retrieveStory_deliversLastInsertedStory() {
        let sut = makeSUT()
        let id = 0
        let firstStory = localStory(with: id, title: "first title")
        let lastStory = localStory(with: id, title: "second title")
        
        insert(firstStory, for: id, into: sut)
        insert(lastStory, for: id, into: sut)
        
        expect(sut, toCompleteWith: found(lastStory), for: id)
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
                        for id: Int,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieve completion")
        sut.retrieve(for: id) { receivedResult in
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
    
    private func insert(_ story: LocalStory, for id: Int, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = LocalFeedId(id: 0)
        let exp = expectation(description: "Wait for cache completion")
        sut.insert([feed], timestamp: Date()) { result in
            switch result {
            case let .failure(error):
                XCTFail("Failed to save \(feed) with error \(error)")
            case .success:
                sut.insert(story) { result in
                    if case let .failure(error) = result {
                        XCTFail("Failed to insert \(story) with error \(error)")
                    }
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func notFound() -> StoryStore.RetrievalResult {
        .success(.none)
    }
    
    private func found(_ story: LocalStory) -> StoryStore.RetrievalResult {
        return .success(story)
    }
    
    private func anyId(_ id: Int = 0) -> Int { id }
    
    private func localStory(with id: Int = 0, title: String = "a title") -> LocalStory {
         LocalStory(
            id: id,
            title: title,
            text: nil,
            author: "an author",
            score: 1,
            createdAt: Date(),
            totalComments: 0,
            comments: nil,
            type: "story",
            url: nil)
    }
}
