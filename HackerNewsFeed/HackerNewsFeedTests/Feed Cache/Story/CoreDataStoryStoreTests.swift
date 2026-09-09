//
//  CoreDataStoryStoreTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

import XCTest
import HackerNewsFeed

class CoreDataStoryStoreTests: XCTestCase {
    
    func test_retrieveStory_deliversNotFoundWhenNotEmpty() throws {
        try makeSUT { sut in
            expect(sut, toCompleteWith: notFound(), for: anyId())
        }
    }
    
    func test_retrieveStory_deliversNotFoundWhenStoredStoryDoesNotMatch() throws {
        try makeSUT { sut in
            let id = 0
            let story = localStory(with: id)
            let nonMatchingId = anyId(1)
            
            insert(story, for: id, into: sut)
            
            expect(sut, toCompleteWith: notFound(), for: nonMatchingId)
        }
    }
    
    func test_retrieveStory_deliversFoundStoryWhenThereIsAStoreStoryMatchingID() throws {
        try makeSUT { sut in
            let matchingId = 0
            let story = localStory(with: matchingId)
            
            insert(story, for: matchingId, into: sut)
            
            expect(sut, toCompleteWith: found(story), for: matchingId)
        }
    }
    
    func test_retrieveStory_deliversLastInsertedStory() throws {
        try makeSUT { sut in
            let id = 0
            let firstStory = localStory(with: id, title: "first title")
            let lastStory = localStory(with: id, title: "second title")
            
            insert(firstStory, for: id, into: sut)
            insert(lastStory, for: id, into: sut)
            
            expect(sut, toCompleteWith: found(lastStory), for: id)
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(_ test: @escaping (CoreDataFeedStore) -> Void, file: StaticString = #file, line: UInt = #line) throws {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        let exp = expectation(description: "wait for completion")
        
        sut.perform {
            test(sut)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}

func expect(_ sut: CoreDataFeedStore,
            toCompleteWith expectedResult: Result<LocalStory?, Error>,
            for id: Int,
            file: StaticString = #file,
            line: UInt = #line) {
    let receivedResult = Result {
        try sut.retrieve(for: id)
    }
    switch (receivedResult, expectedResult) {
    case let (.success(receivedStory), .success(expectedStory)):
        XCTAssertEqual(receivedStory, expectedStory, file: file, line: line)
    default:
        XCTFail("Expected \(expectedResult), got result \(receivedResult) instead", file: file, line: line)
    }
}

func insert(_ story: LocalStory, for id: Int, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
    let feed = LocalFeedId(id: 0)
    do {
        try sut.insert([feed], timestamp: Date())
    } catch {
        XCTFail("Failed to save \(feed) with error \(error)")
    }
    
    do {
        try sut.insert(story: story)
    } catch {
        XCTFail("Failed to insert \(story) with error \(error)")
    }
}

func notFound() -> Result<LocalStory?, Error> {
    .success(.none)
}

func found(_ story: LocalStory) -> Result<LocalStory?, Error> {
    return .success(story)
}

func anyId(_ id: Int = 0) -> Int { id }

func localStory(with id: Int = 0, title: String = "a title") -> LocalStory {
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
