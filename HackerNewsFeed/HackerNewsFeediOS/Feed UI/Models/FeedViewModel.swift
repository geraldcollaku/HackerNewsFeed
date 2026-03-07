//
//  FeedViewModel.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 07.03.26.
//

import HackerNewsFeed

public final class FeedViewModel {
    private let feedIdLoader: FeedLoader
    
    public init(feedIdLoader: FeedLoader) {
        self.feedIdLoader = feedIdLoader
    }
    
    public var onChange: ((FeedViewModel) -> Void)?
    public var onFeedLoad: (([FeedId]) -> Void)?
    
    public var isLoading: Bool = false {
        didSet {
            onChange?(self)
        }
    }
    
    public func loadFeed() {
        isLoading = true
        feedIdLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        }
    }
}
