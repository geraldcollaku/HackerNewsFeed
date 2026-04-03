//
//  StoryCache.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 03.04.26.
//

public protocol StoryCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ story: Story, completion: @escaping (Result) -> Void)
}
