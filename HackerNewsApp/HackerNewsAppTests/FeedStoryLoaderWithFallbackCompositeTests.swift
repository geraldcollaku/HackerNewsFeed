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
    
    private class Task: StoryLoaderTask {
        func cancel() { }
    }
    
    func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
        _ = primary.loadStory(with: id) { _ in }
        return Task()
    }
}

class FeedStoryLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_loadStory_loadsFromPrimaryLoaderFirst() {
        let story = uniqueStory()
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        
        let sut = FeedStoryLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        _ = sut.loadStory(with: story.id) { _ in }
        
        XCTAssertEqual(primaryLoader.ids, [story.id], "Expected to load story with ID from primary loader")
        XCTAssertTrue(fallbackLoader.ids.isEmpty, "Expected no loaded IDs in the fallback loader")
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
        private class Task: StoryLoaderTask {
            func cancel() {}
        }
        
        var ids: [Int] {
            messages.map { $0.id }
        }
        
        private var messages = [(id: Int, completion: ((StoryLoader.Result) -> Void))]()
        
        func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
            messages.append((id, completion))
            return Task()
        }
    }
}
