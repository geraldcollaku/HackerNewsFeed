//
//  LoaderSpy.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.03.26.
//

import Foundation
import HackerNewsFeed
import HackerNewsFeediOS

class LoaderSpy: FeedLoader, StoryLoader {
    private var feedIdRequests = [(FeedLoader.Result) -> Void]()
    
    var loadFeedIdCallCount: Int {
        return feedIdRequests.count
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        feedIdRequests.append(completion)
    }
    
    func completeFeedLoading(with news: [FeedId] = [], at index: Int = 0) {
        feedIdRequests[index](.success(news))
    }
    
    // MARK: - StoryLoader
    
    private struct StoryLoaderTaskSpy: StoryLoaderTask {
        var cancelCallback: () -> Void
        
        func cancel() {
            cancelCallback()
        }
    }
    
    private(set) var storiesRequests = [(id: Int, completion: (StoryLoader.Result) -> Void)]()
    
    private(set) var cancelledStoriesIds = [Int]()
    
    func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
        storiesRequests.append((id, completion))
        return StoryLoaderTaskSpy { [weak self] in
            self?.cancelledStoriesIds.append(id)
        }
    }
    
    func completeStoryLoading(with story: Story = .any, at index: Int = 0) {
        storiesRequests[index].completion(.success(story))
    }
    
    func completeStoryLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        storiesRequests[index].completion(.failure(error))
    }
}
