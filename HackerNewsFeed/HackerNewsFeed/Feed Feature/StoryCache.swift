//
//  StoryCache.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 03.04.26.
//

public protocol StoryCache {
    func save(_ story: Story) throws
}
