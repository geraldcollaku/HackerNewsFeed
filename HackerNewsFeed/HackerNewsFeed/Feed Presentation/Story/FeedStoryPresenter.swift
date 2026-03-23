//
//  FeedStoryPresenter.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 23.03.26.
//

import Foundation

public protocol FeedStoryView {
    func display(_ viewModel: FeedStoryViewModel)
}

public protocol FeedStoryLoadingView {
    func display(_ viewModel: FeedStoryLoadingViewModel)
}

public protocol FeedStoryErrorView {
    func display(_ viewModel: FeedStoryErrorViewModel)
}

public final class FeedStoryPresenter {
    private let storyView: FeedStoryView
    private let loadingView: FeedStoryLoadingView
    private let errorView: FeedStoryErrorView
    
    private var storyErrorMessage: String {
        NSLocalizedString("FEED_STORY_VIEW_CONNECTION_ERROR",
                          tableName: "Story",
                          bundle: Bundle(for: FeedStoryPresenter.self),
                          comment: "Error message displayed when we can't load story from the server")
    }
    
    public init(storyView: FeedStoryView, loadingView: FeedStoryLoadingView, errorView: FeedStoryErrorView) {
        self.storyView = storyView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public func didStartLoadingStory() {
        loadingView.display(.loading)
        errorView.display(.none)
        storyView.display(.noStory)
    }
    
    public func didFinishLoadingStory(with model: Story) {
        loadingView.display(.stopped)
        errorView.display(.none)
        storyView.display(FeedStoryViewModel(
            author: model.author,
            title: model.title,
            score: String(model.score ?? 0),
            url: model.url?.absoluteString))
    }
    
    public func didFinishLoadingStory(with error: Error) {
        loadingView.display(.stopped)
        errorView.display(.error(message: storyErrorMessage))
    }
}
