//
//  LoadResourcePresenter.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 16.05.26.
//

import Foundation

public final class LoadResourcePresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    public static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: LoadResourcePresenter.self),
                          comment: "Title for the feed view")
    }
    
    private var feedErrorTitle: String {
        NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                          tableName: "Feed",
                          bundle: Bundle(for: LoadResourcePresenter.self),
                          comment: "Error message displayed when we can't load feed from the server")
    }
    
    public init(feedView: FeedView,
         loadingView: FeedLoadingView,
         errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedId]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedErrorTitle))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
