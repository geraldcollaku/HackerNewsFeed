//
//  FeedPresenter.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 07.03.26.
//

import HackerNewsFeed

public protocol FeedView {
    func display(feed: [FeedId])
}

public protocol FeedLoadingView {
    func display(isLoading: Bool)
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
        loadingView?.display(isLoading: true)
        feedIdLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feed: feed)
            }
            self?.loadingView?.display(isLoading: false)

        }
    }
}
