//
//  StoryStore.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

public protocol StoryStore {
    typealias RetrievalResult = Swift.Result<LocalStory?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    func retrieve(for id: Int, completion: @escaping (RetrievalResult) -> Void)
    func insert(_ story: LocalStory, completion: @escaping (InsertionResult) -> Void)
}
