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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalStoryLoader, store: FeedStoryStoreSpy) {
        let store = FeedStoryStoreSpy()
        let sut = LocalStoryLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
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
}

