//
//  FeedLoaderStub.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 03.04.26.
//

import HackerNewsFeed

class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
