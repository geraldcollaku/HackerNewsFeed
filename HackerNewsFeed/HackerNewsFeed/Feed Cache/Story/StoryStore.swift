//
//  StoryStore.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

import Foundation

public protocol StoryStore {
    typealias RetrievalResult = Swift.Result<LocalStory?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    func insert(story: LocalStory) throws
    func retrieve(for id: Int) throws -> LocalStory?
    
    @available(*, deprecated)
    func retrieve(for id: Int, completion: @escaping (RetrievalResult) -> Void)
    @available(*, deprecated)
    func insert(_ story: LocalStory, completion: @escaping (InsertionResult) -> Void)
}

public extension StoryStore {
    func insert(story: LocalStory) throws {
        let group = DispatchGroup()
        group.enter()
        var result: InsertionResult!
        insert(story){
            result = $0
            group.leave()
        }
        group.wait()
        return try result.get()
    }
    
    func retrieve(for id: Int) throws -> LocalStory? {
        let group = DispatchGroup()
        group.enter()
        var result: RetrievalResult!
        retrieve(for: id) {
            result = $0
            group.leave()
        }
        group.wait()
        return try result.get()
    }
    
    func retrieve(for id: Int, completion: @escaping (RetrievalResult) -> Void) {}
    func insert(_ story: LocalStory, completion: @escaping (InsertionResult) -> Void) {}
}
