//
//  StoryStore.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

import Foundation

public protocol StoryStore {
    func insert(story: LocalStory) throws
    func retrieve(for id: Int) throws -> LocalStory?
}
