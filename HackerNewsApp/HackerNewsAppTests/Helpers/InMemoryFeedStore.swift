//
//  InMemoryFeedStore.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 07.09.26.
//

import HackerNewsFeed
import Foundation

class InMemoryFeedStore: FeedStore {
    private(set) var feedCache: CachedFeed?
    private var storyCache: [Int: LocalStory] = [:]
    
    init(feedCache: CachedFeed? = nil) {
        self.feedCache = feedCache
    }
    
    func deleteCachedFeed() throws {
        feedCache = nil
    }
    
    func insert(_ feed: [LocalFeedId], timestamp: Date) throws {
        feedCache =  CachedFeed(feed: feed, timestamp: timestamp)
    }
    
    func retrieve() throws -> CachedFeed? {
        feedCache
    }
}

extension InMemoryFeedStore: StoryStore {
    
    func insert(story: LocalStory) throws {
        storyCache[story.id] = story
    }
    
    func retrieve(for id: Int) throws -> LocalStory? {
        storyCache[id]
    }
}

extension InMemoryFeedStore {
    
    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }
    
    static var withExpiredCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date.distantPast))
    }
    
    static var withNonExpiredCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date()))
    }
}
