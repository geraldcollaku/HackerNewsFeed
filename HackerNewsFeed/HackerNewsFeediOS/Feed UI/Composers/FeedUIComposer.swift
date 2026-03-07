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
        refreshController.onRefresh = { [weak feedController] feed in
            feedController?.tableModel = feed.map { model in
                FeedStoryCellController(model: model, storyLoader: storyLoader)
            }
        }
        
        return feedController
    }
}
