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
        let received = FeedEndpoint.get.url(baseURL: baseURL)
        let expected = URL(string: "http://base-url.com/v0/newstories?page=1")
        
        XCTAssertEqual(received, expected)
    }
}
