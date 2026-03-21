//
//  FeedLoaderPresentationAdapter.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 21.03.26.
//

import HackerNewsFeed

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedIdLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedIdLoader: FeedLoader) {
        self.feedIdLoader = feedIdLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedIdLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
