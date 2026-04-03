//
//  FeedStoryLoaderCacheDecoratorTests.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 03.04.26.
//

import XCTest
import HackerNewsFeed

class FeedStoryLoaderCacheDecorator: StoryLoader {
    private let decoratee: StoryLoader
    
    init(decoratee: StoryLoader) {
        self.decoratee = decoratee
    }
    
    func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
        return decoratee.loadStory(with: id, completion: completion)
    }
}

class FeedStoryLoaderCacheDecoratorTests: XCTestCase, StoryLoaderTestCase {
    
    func test_init_doesNotLoadStoryData() {
        let (_, loader) = makeSUT()
        
        XCTAssertTrue(loader.messages.isEmpty, "Expected no loaded Story")
    }
    
    func test_loadStory_loadsFromLoader() {
        let (sut, loader) = makeSUT()
        let storyId = 0
        
        sut.loadStory(with: storyId) { _ in }
        
        XCTAssertEqual(loader.loadedIds, [storyId], "Expected to load story with ID")
    }
    
    func test_cancelStory_cancelsLoaderTask() {
        let storyId = 0
        let (sut, loader) = makeSUT()

        let task = sut.loadStory(with: storyId) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledIds, [storyId], "Expected to cancel story with ID")
    }
    
    func test_loadStory_deliversStoryOnLoaderSuccess() {
        let (sut, loader) = makeSUT()
        let story = uniqueStory()
        
        expect(sut, for: story.id, toCompleteWith: .success(story), when: {
            loader.complete(with: story)
        })
    }
    
    func test_loadStory_deliversErrorOnLoaderFailure() {
        let (sut, loader) = makeSUT()
        let storyId = 0
        
        expect(sut, for: storyId, toCompleteWith: .failure(anyNSError()), when: {
            loader.complete(with: anyNSError())
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: StoryLoader, loader: StoryLoaderSpy) {
        let loader = StoryLoaderSpy()
        let sut = FeedStoryLoaderCacheDecorator(decoratee: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    private func uniqueStory(id: Int = Int.random(in: 0...100)) -> Story {
        Story(
            id: id,
            title: "a title",
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
