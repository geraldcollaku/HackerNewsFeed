//
//  SharedTestHelpers.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 02.04.26.
//

import Foundation
import HackerNewsFeed

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func uniqueIdFeed(id: Int = Int.random(in: 0...100)) -> [FeedId] {
    [FeedId(id: id)]
}

func uniqueStory(id: Int = Int.random(in: 0...100)) -> Story {
    Story(
        id: id,
        title: "a title",
        text: nil,
        author: "an author",
        score: 1,
        createdAt: Date(),
        totalComments: 0,
        comments: nil,
        type: "story",
        url: nil)
}
