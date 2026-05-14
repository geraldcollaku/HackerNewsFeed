//
//  FeedCommentsMapperTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 13.05.26.
//

import XCTest
import HackerNewsFeed

class FeedCommentsMapperTests: XCTestCase {
    
    func test_load_deliversErrorOnNon2xxHTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 150, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        let samples = [200, 201, 250, 280, 299]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let invalidJSON = Data.init("invalid data".utf8)
                client.complete(withStatusCode: code, data: invalidJSON, at: index)
            })
        }
    }
    
    func test_load_deliversEmptyOn2xxHTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        let samples = [200, 201, 250, 280, 299]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success([]), when: {
                let emptyJSONList = makeItemsJSON([])
                client.complete(withStatusCode: code, data: emptyJSONList, at: index)
            })
        }
    }
    
    func test_load_deliversItemsOn2xxHTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
         
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
        
        let samples = [200, 201, 250, 280, 299]
            
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success([item1.model, item2.model]), when: {
                let json = makeItemsJSON([item1.json, item2.json])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCommentsLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteCommentsLoader.Error) -> RemoteCommentsLoader.Result {
        .failure(error)
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
    
    private func makeItemsJSON(_ items: [[String : Any]]) -> Data {
        let json = try! JSONSerialization.data(withJSONObject: items)
        return json
    }
    
    private func expect(_ sut: RemoteCommentsLoader,
                        toCompleteWith expectedResult: RemoteCommentsLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteCommentsLoader.Error), .failure(expectedError as RemoteCommentsLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result: \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private struct Task: HTTPClientTask {
            func cancel() {}
        }
        
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
                
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url, completion))
            return Task()
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
}
