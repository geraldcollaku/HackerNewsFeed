//
//  FeedItemsMapperTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 23.12.25.
//

import XCTest
import HackerNewsFeed

class FeedItemsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let json = makeItemsJSON([])
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(json, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data.init("invalid data".utf8)
        
        XCTAssertThrowsError(
            try FeedItemsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws {
        let emptyJSONList = makeItemsJSON([])

        let result = try FeedItemsMapper.map(emptyJSONList, from: HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(result, [])
    }
    
    func test_map_deliversItemsOn200HTTPResponseWithJSONItems() throws {
        let item1 = makeItem(id: 1)
        let item2 = makeItem(id: 2)
        
        let json = makeItemsJSON([item1.id, item2.id])

        let result = try FeedItemsMapper.map(json, from: HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(result, [item1, item2])
    }
    
    // MARK: - Helpers
    
    private func makeItem(id: Int) -> FeedId {
        let item = FeedId(id: id)
        return item
    }
    
    private func makeItemsJSON(_ items: [Int]) -> Data {
        let json = try! JSONSerialization.data(withJSONObject: ["ids": items])
        return json
    }
}

private extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
