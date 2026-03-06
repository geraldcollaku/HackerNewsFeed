//
//  StoryLoader.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.03.26.
//

public protocol StoryLoaderTask {
    func cancel()
}

public protocol StoryLoader {
    typealias Result = Swift.Result<Story, Error>
    
    func loadStory(with id: Int, completion: @escaping (Result) -> Void) -> StoryLoaderTask
}
