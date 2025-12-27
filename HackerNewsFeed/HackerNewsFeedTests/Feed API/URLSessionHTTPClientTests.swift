//
//  URLSessionHTTPClientTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 27.12.25.
//

import XCTest

class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_createsDataTask() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let client = URLSessionHTTPClient(session: session)
        
        client.get(from: url)
        
        XCTAssertEqual(session.receivedURL, url)
    }
    
    // MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        var receivedURL: URL?
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
            self.receivedURL = url
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask { }
}
