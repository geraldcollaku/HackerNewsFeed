//
//  HackerNewsFeedAPIEndToEndTests.swift
//  HackerNewsFeedAPIEndToEndTests
//
//  Created by Gerald Collaku on 29.12.25.
//

import XCTest
import HackerNewsFeed

final class HackerNewsFeedAPIEndToEndTests: XCTestCase {
    
    func test_endToEndTestGetFeedResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(items)?:
            XCTAssertEqual(items.count, 7, "Expected 7 items in the test account")
            
            XCTAssertEqual(items[0], expectedItem(at: 0))
            XCTAssertEqual(items[1], expectedItem(at: 1))
            XCTAssertEqual(items[2], expectedItem(at: 2))
            XCTAssertEqual(items[3], expectedItem(at: 3))
            XCTAssertEqual(items[4], expectedItem(at: 4))
            XCTAssertEqual(items[5], expectedItem(at: 5))
            XCTAssertEqual(items[6], expectedItem(at: 6))
            
        case let .failure(error):
            XCTFail("Expected successful feed result, got \(error) instead")
        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }
    
    // MARK: - Helpers
    
    private func getFeedResult() -> LoadFeedResult? {
        let testServerURL = URL(string: "https://hackernews-fa652-default-rtdb.europe-west1.firebasedatabase.app/items.json")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(url: testServerURL, client: client)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: LoadFeedResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private func expectedItem(at index: Int) -> FeedItem {
        FeedItem(id: id(at: index))
    }
    
    private func id(at index: Int) -> Int {
        return [
            46383452,
            46391572,
            46385197,
            46380168,
            46414570,
            46413685,
            46412006
        ][index]
    }
}
