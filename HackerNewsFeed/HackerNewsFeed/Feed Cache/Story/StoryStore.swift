//
//  StoryStore.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

public protocol StoryStore {
    typealias Result = Swift.Result<LocalStory?, Error>
    
    func retrieve(for id: Int, completion: @escaping (Result) -> Void)
}
