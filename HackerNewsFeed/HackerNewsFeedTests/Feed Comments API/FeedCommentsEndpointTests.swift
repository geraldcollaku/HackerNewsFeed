//
//  FeedCommentsEndpointTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 02.06.26.
//

import XCTest
import HackerNewsFeed

class FeedCommentsEndpointTests: XCTestCase {
    
    func test_feedComments_endpointURL() {
        let id = 0
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = FeedCommentsEndpoint.get(id).url(baseURL: baseURL)
        let expected = URL(string: "http://base-url.com/v0/story/0/comments")!
        
        XCTAssertEqual(received, expected)
    }
}
