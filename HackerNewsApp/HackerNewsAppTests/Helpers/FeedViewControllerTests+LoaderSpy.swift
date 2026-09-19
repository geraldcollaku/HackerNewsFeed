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

extension FeedUIIntegrationTests {
    @MainActor
    class LoaderSpy {
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
        
        private var storyLoader = HackerNewsAppTests.LoaderSpy<Int, Story>()
        
        var storyRequests: [Int] {
            storyLoader.requests.map { $0.param }
        }
        
        var storyIds: [Int] {
            storyRequests
        }
        
        var cancelledStoriesIds: [Int] {
            storyLoader.requests.filter { $0.result == .cancelled}.map { $0.param }
        }
        
        private struct NoResponse: Error {}
        private struct Timeout: Error {}
        
        func loadStory(with id: Int) async throws-> Story {
            return try await storyLoader.load(with: id)
        }
        
        func completeStoryLoading(with story: Story = .any, at index: Int = 0) {
            storyLoader.complete(with: story, at: index)
        }
        
        func completeStoryLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            storyLoader.fail(with: error, at: index)
        }
        
        func storyResult(at index: Int, timeout: TimeInterval = 1) async throws -> AsyncResult {
            try await storyLoader.result(at: index, timeout: timeout)
        }
        
        func cancelPendingRequests() async throws {
            try await storyLoader.cancelPendingRequests()
        }
    }
}
