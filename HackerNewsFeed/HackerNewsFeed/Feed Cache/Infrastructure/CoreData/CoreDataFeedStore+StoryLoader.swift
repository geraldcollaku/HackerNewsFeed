//
//  CoreDataFeedStore+StoryLoader.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 30.03.26.
//

extension CoreDataFeedStore: StoryStore {
    public func insert(_ story: LocalStory, completion: @escaping (StoryStore.InsertionResult) -> Void) {
        
    }
    public func retrieve(for id: Int, completion: @escaping (StoryStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}
