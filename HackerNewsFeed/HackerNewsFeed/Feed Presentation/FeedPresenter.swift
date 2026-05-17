//
//  FeedPresenter.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 22.03.26.
//

import Foundation

public final class FeedPresenter {
    public static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Title for the feed view")
    }

    public static func map(_ feed: [FeedId]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }
}
