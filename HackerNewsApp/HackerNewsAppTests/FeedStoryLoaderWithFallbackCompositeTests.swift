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
    
    init(primary: StoryLoader, fallback: StoryLoader) {
        self.primary = primary
    }
    
    private class TaskWrapper: StoryLoaderTask {
        var wrapped: StoryLoaderTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primary.loadStory(with: id, completion: completion)
        return task
    }
    
}

class FeedStoryLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_loadStory_deliversPrimaryStoryOnPrimaryLoaderSuccess() {
        let primaryStory = uniqueStory()
        let fallbackStory = uniqueStory()
        let primaryLoader = LoaderStub(result: .success(primaryStory))
        let fallbackLoader = LoaderStub(result: .success(fallbackStory))
        
        let sut = FeedStoryLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        let exp = expectation(description: "Wait for load story completion")
        _ = sut.loadStory(with: 0) { result in
            switch result {
            case .success(let receivedStory):
                XCTAssertEqual(receivedStory, primaryStory)
            case .failure:
                XCTFail("Expected success, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
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
    
    private class LoaderStub: StoryLoader {
        private class Task: StoryLoaderTask {
            func cancel() {}
        }
        
        private let result: StoryLoader.Result
        
        init(result: StoryLoader.Result) {
            self.result = result
        }
        
        func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
            completion(result)
            return Task()
        }
    }
}
