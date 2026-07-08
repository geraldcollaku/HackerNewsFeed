//
//  StoryLoader.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.03.26.
//

import Foundation

public protocol StoryLoader {
    func loadStory(with id: Int) throws -> Story
}
