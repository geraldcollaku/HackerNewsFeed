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
import HackerNewsApp

class LoaderSpy: StoryLoader {
    private var feedIdRequests = [PassthroughSubject<Paginated<FeedId>, Error>]()
    private var loadMoreRequests = [PassthroughSubject<Paginated<FeedId>, Error>]()

    var loadFeedIdCallCount: Int {
        return feedIdRequests.count
    }
    
    var loadMoreCallCount: Int {
        loadMoreRequests.count
    }
    
    func loadPublisher() -> AnyPublisher<Paginated<FeedId>, Error> {
        let publisher = PassthroughSubject<Paginated<FeedId>, Error>()
        feedIdRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }
    
    func completeFeedLoading(with news: [FeedId] = [], at index: Int = 0) {
        feedIdRequests[index].send(Paginated(items: news, loadMorePublisher: { [weak self]  in
            let publisher = PassthroughSubject<Paginated<FeedId>, Error>()
            self?.loadMoreRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }))
        feedIdRequests[index].send(completion: .finished)
    }
    
    func completeFeedLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        feedIdRequests[index].send(completion: .failure(error))
    }
    
    func completeLoadMore(with news: [FeedId] = [], lastPage: Bool = false, at index: Int = 0) {
        loadMoreRequests[index].send(Paginated(
            items: news,
            loadMorePublisher: lastPage ? nil : { [weak self] in
                let publisher = PassthroughSubject<Paginated<FeedId>, Error>()
                self?.loadMoreRequests.append(publisher)
                return publisher.eraseToAnyPublisher()
            }))
    }
    
    func completeLoadMoreWithError(at index: Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        loadMoreRequests[index].send(completion: .failure(error))
    }
    
    // MARK: - StoryLoader
    
    private struct StoryLoaderTaskSpy: StoryLoaderTask {
        var cancelCallback: () -> Void
        
        func cancel() {
            cancelCallback()
        }
    }
    
    private(set) var storiesRequests = [(id: Int, completion: (StoryLoader.Result) -> Void)]()
    var storyIds: [Int] {
        storiesRequests.map { $0.id }
    }
    
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
