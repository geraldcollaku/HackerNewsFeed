//
//  CacheFeedUseCaseTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 09.01.26.
//

import XCTest
import HackerNewsFeed

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items)
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    var deleteCachedFeedCallCount = 0
    var insertCallCount = 0
    
    private var deletionCompletions = [DeletionCompletion]()
    
    func deleteCachedFeed(completion: @escaping (Error?) -> Void) {
        deleteCachedFeedCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func insert(_ items: [FeedItem]) {
        insertCallCount += 1
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)

    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }

}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(0), uniqueItem(1)]
        
        sut.save(items)

        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(0), uniqueItem(1)]
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(0), uniqueItem(1)]
        
        sut.save(items)
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueItem(_ id: Int) -> FeedItem {
        FeedItem(id: id)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any", code: 0)
    }
}
