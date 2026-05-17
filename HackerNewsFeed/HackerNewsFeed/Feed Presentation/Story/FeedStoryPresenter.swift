//
//  FeedStoryPresenter.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 23.03.26.
//

import Foundation

public final class FeedStoryPresenter {
    public static func map(_ story: Story) -> FeedStoryViewModel {
        FeedStoryViewModel(
            author: story.author,
            title: story.title,
            score: String(story.score ?? 0),
            url: story.url?.absoluteString)
    }
}
