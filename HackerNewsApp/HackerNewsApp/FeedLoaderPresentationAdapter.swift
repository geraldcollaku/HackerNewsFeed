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
    private let feedIdLoader: () -> AnyPublisher<[FeedId], Error>
    var presenter: LoadResourcePresenter<[FeedId], FeedViewAdapter>?
    var cancellable: Cancellable?
    
    init(feedIdLoader: @escaping () -> AnyPublisher<[FeedId], Error>) {
        self.feedIdLoader = feedIdLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        cancellable = feedIdLoader().sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished: break
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
        }, receiveValue: { [weak self] feed in
            self?.presenter?.didFinishLoading(with: feed)
        })
    }
}
