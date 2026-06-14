//
//  LoaderSpy.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.03.26.
//

import Foundation
import Combine
import HackerNewsFeed
import HackerNewsFeediOS

class LoaderSpy: StoryLoader {
    private var feedIdRequests = [PassthroughSubject<Paginated<FeedId>, Error>]()
    
    var loadFeedIdCallCount: Int {
        return feedIdRequests.count
    }
    
    private(set) var loadMoreCallCount = 0
    
    func loadPublisher() -> AnyPublisher<Paginated<FeedId>, Error> {
        let publisher = PassthroughSubject<Paginated<FeedId>, Error>()
        feedIdRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }
    
    func completeFeedLoading(with news: [FeedId] = [], at index: Int = 0) {
        feedIdRequests[index].send(Paginated(items: news, loadMore: { [weak self] _ in
            self?.loadMoreCallCount += 1
        }))
    }
    
    func completeFeedLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        feedIdRequests[index].send(completion: .failure(error))
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
