//
//  FeedStoryPresenter.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 23.03.26.
//

import Foundation

public final class FeedStoryPresenter {
    private var storyErrorMessage: String {
        NSLocalizedString("FEED_STORY_VIEW_CONNECTION_ERROR",
                          tableName: "Story",
                          bundle: Bundle(for: FeedStoryPresenter.self),
                          comment: "Error message displayed when we can't load story from the server")
    }

    public static func map(_ story: Story) -> FeedStoryViewModel {
        FeedStoryViewModel(
            author: story.author,
            title: story.title,
            score: String(story.score ?? 0),
            url: story.url?.absoluteString)
    }
}
