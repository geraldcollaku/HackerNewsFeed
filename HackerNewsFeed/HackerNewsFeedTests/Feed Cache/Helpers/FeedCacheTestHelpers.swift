//
//  FeedCacheTestHelpers.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 18.01.26.
//

import Foundation
import HackerNewsFeed

func uniqueIdFeed() -> (models: [FeedId], local: [LocalFeedId]) {
    let models = [uniqueId(0), uniqueId(1)]
    let local = models.map { LocalFeedId(id: $0.id)}
    return (models, local)
}

func uniqueId(_ id: Int) -> FeedId {
    FeedId(id: id)
}

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int { 7 }
    
    private func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}

