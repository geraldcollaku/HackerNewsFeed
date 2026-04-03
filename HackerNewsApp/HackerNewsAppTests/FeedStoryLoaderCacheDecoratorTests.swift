//
//  FeedStoryLoaderCacheDecoratorTests.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 03.04.26.
//

import XCTest
import HackerNewsFeed

protocol StoryCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ story: Story, completion: @escaping (Result) -> Void)
}

class FeedStoryLoaderCacheDecorator: StoryLoader {
    private let decoratee: StoryLoader
    private let cache: StoryCache
    
    init(decoratee: StoryLoader, cache: StoryCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
        return decoratee.loadStory(with: id) { [weak self] result in
            if let story = try? result.get() {
                self?.cache.save(story) { _ in }
            }
            completion(result)
        }
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
    
    func test_loadStory_cachesStoryDataOnLoaderSuccess() {
        let cache = CacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        let story = uniqueStory()
        
        _ = sut.loadStory(with: story.id) { _ in }
        loader.complete(with: story)
        
        XCTAssertEqual(cache.messages, [.save(story)])
    }
    
    func test_loadStory_doesNotCacheStoryDataOnLoaderFailure() {
        let cache = CacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        let story = uniqueStory()
        
        _ = sut.loadStory(with: story.id) { _ in }
        loader.complete(with: anyNSError())
        
        XCTAssertTrue(cache.messages.isEmpty, "Expected no story cache on loader failure")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, cache: CacheSpy = .init(), line: UInt = #line) -> (sut: StoryLoader, loader: StoryLoaderSpy) {
        let loader = StoryLoaderSpy()
        let sut = FeedStoryLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    private class CacheSpy: StoryCache {
        enum Message: Equatable {
            case save(Story)
        }
        
        private(set) var messages = [Message]()
        
        func save(_ story: Story, completion: @escaping (StoryCache.Result) -> Void) {
            messages.append(.save(story))
            completion(.success(()))
        }
    }
}
