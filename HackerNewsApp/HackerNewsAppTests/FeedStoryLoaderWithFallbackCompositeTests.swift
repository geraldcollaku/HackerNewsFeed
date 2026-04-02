//
//  FeedStoryLoaderWithFallbackCompositeTests.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 02.04.26.
//

import XCTest
import HackerNewsFeed

final class FeedStoryLoaderWithFallbackComposite: StoryLoader {
    private let primary: StoryLoader
    private let fallback: StoryLoader
    
    init(primary: StoryLoader, fallback: StoryLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    private class TaskWrapper: StoryLoaderTask {
        var wrapped: StoryLoaderTask?
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primary.loadStory(with: id) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure:
                _ = self?.fallback.loadStory(with: id) { _ in }
            }
        }
        return task
    }
}

class FeedStoryLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_loadStory_loadsFromPrimaryLoaderFirst() {
        let story = uniqueStory()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        _ = sut.loadStory(with: story.id) { _ in }
        
        XCTAssertEqual(primaryLoader.ids, [story.id], "Expected to load story with ID from primary loader")
        XCTAssertTrue(fallbackLoader.ids.isEmpty, "Expected no loaded IDs in the fallback loader")
    }
    
    func test_loadStory_loadsFromFallbackOnPrimaryLoaderFailure() {
        let story = uniqueStory()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        _ = sut.loadStory(with: story.id) { _ in }
        
        primaryLoader.complete(with: anyNSError())
        
        XCTAssertEqual(primaryLoader.ids, [story.id], "Expected to load story with ID from primary loader")
        XCTAssertEqual(fallbackLoader.ids, [story.id], "Expected to load story with ID from fallback loader")
    }
    
    func test_loadStory_cancelsPrimaryLoaderTaskOnCancel() {
        let story = uniqueStory()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        let task = sut.loadStory(with: story.id) { _ in }
        task.cancel()
        
        XCTAssertEqual(primaryLoader.cancelledIds, [story.id], "Expected to cancel story loading from primary loader")
        XCTAssertTrue(fallbackLoader.cancelledIds.isEmpty, "Expected no cancelled stories in the fallback loader")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: StoryLoader, primary: LoaderSpy, fallback: LoaderSpy) {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = FeedStoryLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
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
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private class LoaderSpy: StoryLoader {
        private struct Task: StoryLoaderTask {
            let callback: () -> Void
            func cancel() {
                callback()
            }
        }
        
        private(set) var cancelledIds = [Int]()
        
        var ids: [Int] {
            messages.map { $0.id }
        }
        
        private var messages = [(id: Int, completion: ((StoryLoader.Result) -> Void))]()
        
        func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
            messages.append((id, completion))
            return Task { [weak self] in
                self?.cancelledIds.append(id)
            }
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
}
