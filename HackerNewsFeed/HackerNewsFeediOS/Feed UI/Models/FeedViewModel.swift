//
//  FeedViewModel.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 07.03.26.
//

import HackerNewsFeed

public final class FeedViewModel {
    public typealias Observer<T> = (T) -> Void
    
    private let feedIdLoader: FeedLoader
    
    public init(feedIdLoader: FeedLoader) {
        self.feedIdLoader = feedIdLoader
    }
    
    public var onLoadingStateChange: Observer<Bool>?
    public var onFeedLoad: Observer<[FeedId]>?
    
    public func loadFeed() {
        onLoadingStateChange?(true)
        feedIdLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
