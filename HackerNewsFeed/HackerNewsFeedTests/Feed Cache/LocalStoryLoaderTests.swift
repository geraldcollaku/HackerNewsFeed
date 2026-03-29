//
//  LocalStoryLoaderTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

import XCTest

final class LocalStoryLoader {
    init(store: Any) {
        
    }
}

class LocalStoryLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalStoryLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalStoryLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private class FeedStoreSpy {
        let receivedMessages = [Any]()
    }
}
