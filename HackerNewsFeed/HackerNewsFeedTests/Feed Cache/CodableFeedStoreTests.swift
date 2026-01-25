//
//  CodableFeedStoreTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 24.01.26.
//

import XCTest
import HackerNewsFeed

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [LocalFeedId]
        let timestamp: Date
    }
    
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("feed-id.store")
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data.init(contentsOf: storeURL) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.feed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedId], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(feed: feed, timestamp: timestamp))
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("feed-id.store")

        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func tearDown() {
        super.tearDown()
    
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("feed-id.store")

        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for cache retrieval")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for cache retrieval")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver some empty result, got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = CodableFeedStore()
        let timestamp = Date()
        let feed = uniqueIdFeed().local
        let exp = expectation(description: "wait for cache retrieval")
        
        sut.insert(feed, timestamp: timestamp) { error in
            XCTAssertNil(error, "Expected feed to be inserted successfully")
            
            sut.retrieve { result in
                switch result {
                case let .found(receivedFeed, receivedTimestamp):
                    XCTAssertEqual(receivedFeed, feed)
                    XCTAssertEqual(receivedTimestamp, timestamp)

                default:
                    XCTFail("Expected found result with feed \(feed) and timestamp \(timestamp) , got \(result) instead")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
