//
//  FeedStoryLoaderWithFallbackCompositeTests.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 02.04.26.
//

import XCTest
import HackerNewsFeed
import HackerNewsApp

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
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: StoryLoader, primary: LoaderSpy, fallback: LoaderSpy) {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = FeedStoryLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }
    
    private func expect(_ sut: StoryLoader, for id: Int, toCompleteWith expectedResult: StoryLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadStory(with: id) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedStory), .success(expectedStory)):
                XCTAssertEqual(receivedStory, expectedStory, file: file, line: line)
            case (.failure, .failure):
               break
            default:
                XCTFail("Expected expectedResult, got \(expectedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1)
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
        
        func complete(with story: Story, at index: Int = 0) {
            messages[index].completion(.success(story))
        }
    }
}
