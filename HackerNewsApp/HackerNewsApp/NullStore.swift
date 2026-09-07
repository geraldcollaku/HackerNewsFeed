//
//  NullStore.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 28.06.26.
//

import Foundation
import HackerNewsFeed

class NullStore: FeedStore & StoryStore {
    
    func deleteCachedFeed() throws { }
    
    func insert(_ feed: [LocalFeedId], timestamp: Date) throws {}

    func retrieve() throws -> CachedFeed? {
        .none
    }
    
    func insert(story: LocalStory) throws { }
    
    func retrieve(for id: Int) throws -> LocalStory? {
        .none
    }
}
