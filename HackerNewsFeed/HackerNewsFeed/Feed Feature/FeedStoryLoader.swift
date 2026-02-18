//
//  FeedStoryLoader.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 18.02.26.
//

protocol FeedStoryLoader {
    typealias Result = Swift.Result<[FeedStory], Error>
    
    func load(id: Int, completion: @escaping (Result) -> Void)
}
