//
//  StoryLoader.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.03.26.
//

import Foundation

public protocol StoryLoaderTask {
    func cancel()
}

public protocol StoryLoader {
    typealias Result = Swift.Result<Story, Error>
    
    @discardableResult
    func loadStory(from url: URL, completion: @escaping (Result) -> Void) -> StoryLoaderTask
}
