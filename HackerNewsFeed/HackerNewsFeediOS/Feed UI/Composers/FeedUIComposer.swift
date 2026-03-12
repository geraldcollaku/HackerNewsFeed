//
//  FeedUIComposer.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 07.03.26.
//

import HackerNewsFeed

public enum FeedUIComposer {
    
    public static func feedComposedWith(loader: FeedLoader, storyLoader: StoryLoader) -> FeedViewController {
        let presenter = FeedPresenter(feedIdLoader: loader)
        let refreshController = FeedRefreshViewController(presenter: presenter)
        let feedController = FeedViewController(refreshController: refreshController)
        presenter.loadingView = refreshController
        presenter.feedView = FeedViewAdapter(controller: feedController, loader: storyLoader)
        return feedController
    }
}

private class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let loader: StoryLoader
    
    init(controller: FeedViewController, loader: StoryLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(feed: [FeedId]) {
        controller?.tableModel = feed.map { model in
            FeedStoryCellController(viewModel: FeedStoryViewModel(model: model, storyLoader: loader))
        }
    }
}
