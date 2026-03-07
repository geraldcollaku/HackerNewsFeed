//
//  FeedUIComposer.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 07.03.26.
//

import HackerNewsFeed

public enum FeedUIComposer {
    
    public static func feedComposedWith(loader: FeedLoader, storyLoader: StoryLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedIdLoader: loader)
        let feedController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: feedController, loader: storyLoader)
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: StoryLoader) -> ([FeedId]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedStoryCellController(model: model, storyLoader: loader)
            }
        }
    }
}
