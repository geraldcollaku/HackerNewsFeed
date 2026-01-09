//
//  CacheFeedUseCaseTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 09.01.26.
//

import XCTest

class LocalFeedLoader {
    init(store: FeedStore) {
        
    }
}

class FeedStore {
    var deleteCacheCallCount = 0
}


class CacheFeedUseCaseTests: XCTestCase {
    
    func test_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCacheCallCount, 0)
    }
}
