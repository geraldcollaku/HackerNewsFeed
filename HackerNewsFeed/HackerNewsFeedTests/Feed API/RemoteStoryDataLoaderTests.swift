//
//  RemoteStoryDataLoaderTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 24.03.26.
//

import XCTest

class RemoteStoryDataLoader {
    init(client: Any) {
        
    }
}

final class RemoteStoryDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteStoryDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteStoryDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private class HTTPClientSpy {
        private(set) var requestedURLs = [URL]()
    }
}
