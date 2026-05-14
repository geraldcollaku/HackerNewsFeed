//
//  FeedCommentsMapperTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 13.05.26.
//

import XCTest
import HackerNewsFeed

class FeedCommentsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
        let json = makeItemsJSON([])

        let samples = [199, 150, 300, 400, 500]
        
        try samples.forEach { code in
           XCTAssertThrowsError(try FeedCommentsMapper.map(json, from: HTTPURLResponse(statusCode: code)))
        }
    }
    
    func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data.init("invalid data".utf8)

        let samples = [200, 201, 250, 280, 299]
    
        try samples.forEach { code in
            XCTAssertThrowsError(try FeedCommentsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: code)))
        }
    }
    
    func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() throws {
        let emptyJSONList = makeItemsJSON([])

        let samples = [200, 201, 250, 280, 299]
        
        try samples.forEach { code in
            let result = try FeedCommentsMapper.map(emptyJSONList, from: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [])
        }
    }
    
    func test_map_deliversItemsOn2xxHTTPResponseWithJSONItems() throws {         
        let item1 = makeItem(
            id: 1,
            message: "a message",
            createdAt: (Date(timeIntervalSince1970: 1778703786), "2026-05-13T20:23:06.000Z"),
            username: "a username"
        )

        let item2 = makeItem(
            id: 2,
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1778704338), "2026-05-13T20:32:18.000Z"),
            username: "another username"
        )
        
        let json = makeItemsJSON([item1.json, item2.json])
        let samples = [200, 201, 250, 280, 299]
            
        try samples.forEach { code in
            let result = try FeedCommentsMapper.map(json, from: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [item1.model, item2.model])
        }
    }
    
    // MARK: - Helpers
    
    private func makeItemsJSON(_ items: [[String : Any]]) -> Data {
        let json = try! JSONSerialization.data(withJSONObject: items)
        return json
    }
    
    private func makeItem(id: Int, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: FeedComment, json: [String: Any]) {
        let item = FeedComment(id: id, message: message, createdAt: createdAt.date, username: username)
        
        let json: [String : Any] = [
            "id": id,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": username
            ].compactMapValues{ $0 }
        ]
        return (item, json)
    }
}
