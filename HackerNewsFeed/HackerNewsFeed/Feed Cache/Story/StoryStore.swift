//
//  StoryStore.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

public protocol StoryStore {
    typealias Result = Swift.Result<LocalStory?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    func retrieve(for id: Int, completion: @escaping (Result) -> Void)
    func insert(_ story: LocalStory, completion: @escaping (InsertionResult) -> Void)
}
