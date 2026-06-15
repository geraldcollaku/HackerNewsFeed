//
//  FeedEndpointTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 02.06.26.
//

import XCTest
import HackerNewsFeed

class FeedEndpointTests: XCTestCase {
    
    func test_feed_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = FeedEndpoint.get().url(baseURL: baseURL)
        
        XCTAssertEqual(received.scheme, "http", "scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/v0/newstories", "path")
        XCTAssertEqual(received.query, "limit=10", "query")
    }
    
    func test_feed_endpointURLAfterGivenImage() {
        let feed = uniqueId(0)
        let baseURL = URL(string: "http://base-url.com")!

        let received = FeedEndpoint.get(after: feed).url(baseURL: baseURL)
        
        XCTAssertEqual(received.scheme, "http", "scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/v0/newstories", "path")
        XCTAssertEqual(received.query, "limit=10&after_id=\(feed.id)", "query")
        XCTAssertEqual(received.query?.contains("limit=10"), true, "limit query param")
        XCTAssertEqual(received.query?.contains("after_id=\(feed.id)"), true, "after_id query param")
    }
}
