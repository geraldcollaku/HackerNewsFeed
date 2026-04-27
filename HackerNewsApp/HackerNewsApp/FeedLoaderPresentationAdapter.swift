//
//  FeedLoaderPresentationAdapter.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 21.03.26.
//

import HackerNewsFeed
import HackerNewsFeediOS
import Combine

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedIdLoader: () -> FeedLoader.Publisher
    var presenter: FeedPresenter?
    var cancellable: Cancellable?
    
    init(feedIdLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedIdLoader = feedIdLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        cancellable = feedIdLoader().sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished: break
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }, receiveValue: { [weak self] feed in
            self?.presenter?.didFinishLoadingFeed(with: feed)
        })
    }
}
