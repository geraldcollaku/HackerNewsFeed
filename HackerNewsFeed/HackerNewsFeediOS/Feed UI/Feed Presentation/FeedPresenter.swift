//
//  FeedPresenter.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 07.03.26.
//

import HackerNewsFeed

public struct FeedViewModel {
    let feed: [FeedId]
}

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public struct FeedLoadingViewModel {
    let isLoading: Bool
}

public protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

public final class FeedPresenter {
    public typealias Observer<T> = (T) -> Void
    
    private let feedIdLoader: FeedLoader
    
    public init(feedIdLoader: FeedLoader) {
        self.feedIdLoader = feedIdLoader
    }
    
    public var feedView: FeedView?
    public var loadingView: FeedLoadingView?
    
    public func loadFeed() {
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
        feedIdLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(FeedViewModel(feed: feed))
            }
            self?.loadingView?.display(FeedLoadingViewModel(isLoading: false))

        }
    }
}
