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
