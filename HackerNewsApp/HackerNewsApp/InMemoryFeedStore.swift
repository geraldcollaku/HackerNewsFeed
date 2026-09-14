//
//  InMemoryFeedStore.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 13.09.26.
//

import Foundation
import HackerNewsFeed

@MainActor
public class InMemoryFeedStore {
    private(set) var feedCache: CachedFeed?
    private var storyCache: [Int: LocalStory] = [:]
    
    init(feedCache: CachedFeed? = nil) {
        self.feedCache = feedCache
    }
}

extension InMemoryFeedStore: FeedStore {
    public func deleteCachedFeed() throws {
        feedCache = nil
    }
    
    public func insert(_ feed: [LocalFeedId], timestamp: Date) throws {
        feedCache =  CachedFeed(feed: feed, timestamp: timestamp)
    }
    
    public func retrieve() throws -> CachedFeed? {
        feedCache
    }
}

extension InMemoryFeedStore: StoryStore {
    
    public func insert(story: LocalStory) throws {
        storyCache[story.id] = story
    }
    
    public func retrieve(for id: Int) throws -> LocalStory? {
        storyCache[id]
    }
}
