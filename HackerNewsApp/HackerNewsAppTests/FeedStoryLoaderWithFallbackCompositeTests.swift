//
//  FeedStoryLoaderWithFallbackCompositeTests.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 02.04.26.
//

import XCTest
import HackerNewsFeed
import HackerNewsApp

class FeedStoryLoaderWithFallbackCompositeTests: XCTestCase, StoryLoaderTestCase {
    
    func test_loadStory_loadsFromPrimaryLoaderFirst() {
        let story = uniqueStory()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        _ = sut.loadStory(with: story.id) { _ in }
        
        XCTAssertEqual(primaryLoader.loadedIds, [story.id], "Expected to load story with ID from primary loader")
        XCTAssertTrue(fallbackLoader.loadedIds.isEmpty, "Expected no loaded IDs in the fallback loader")
    }
    
    func test_loadStory_loadsFromFallbackOnPrimaryLoaderFailure() {
        let story = uniqueStory()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        _ = sut.loadStory(with: story.id) { _ in }
        
        primaryLoader.complete(with: anyNSError())
        
        XCTAssertEqual(primaryLoader.loadedIds, [story.id], "Expected to load story with ID from primary loader")
        XCTAssertEqual(fallbackLoader.loadedIds, [story.id], "Expected to load story with ID from fallback loader")
    }
    
    func test_loadStory_cancelsPrimaryLoaderTaskOnCancel() {
        let story = uniqueStory()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        let task = sut.loadStory(with: story.id) { _ in }
        task.cancel()
        
        XCTAssertEqual(primaryLoader.cancelledIds, [story.id], "Expected to cancel story loading from primary loader")
        XCTAssertTrue(fallbackLoader.cancelledIds.isEmpty, "Expected no cancelled stories in the fallback loader")
    }
    
    func test_loadStory_cancelsFallbackLoaderTaskOnCancel() {
        let story = uniqueStory()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        let task = sut.loadStory(with: story.id) { _ in }
        primaryLoader.complete(with: anyNSError())
        
        task.cancel()
        
        XCTAssertTrue(primaryLoader.cancelledIds.isEmpty, "Expected to cancel story loading from primary loader")
        XCTAssertEqual(fallbackLoader.cancelledIds, [story.id], "Expected to cancel  story loading in the fallback loader")
    }
    
    func test_loadStory_deliversPrimaryStoryOnPrimaryLoaderSuccess() {
        let primaryStory = uniqueStory()
        let (sut, primaryLoader, _) = makeSUT()
        
        expect(sut, for: primaryStory.id, toCompleteWith: .success(primaryStory), when: {
            primaryLoader.complete(with: primaryStory)
        })
    }
    
    func test_loadStory_deliversFallbackStoryOnFallbackLoaderSuccess() {
        let fallbackStory = uniqueStory()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        expect(sut, for: fallbackStory.id, toCompleteWith: .success(fallbackStory), when: {
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: fallbackStory)
        })
    }
    
    func test_loadStory_deliversOnBothPrimaryAndFallbackLoaderFailure() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        let story = uniqueStory()
        
        expect(sut, for: story.id, toCompleteWith: .failure(anyNSError()), when: {
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: anyNSError())
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: StoryLoader, primary: StoryLoaderSpy, fallback: StoryLoaderSpy) {
        let primaryLoader = StoryLoaderSpy()
        let fallbackLoader = StoryLoaderSpy()
        let sut = FeedStoryLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }
}
