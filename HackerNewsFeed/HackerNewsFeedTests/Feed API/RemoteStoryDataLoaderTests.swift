//
//  RemoteStoryDataLoaderTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 24.03.26.
//

import XCTest
import HackerNewsFeed

class RemoteStoryDataLoader {
    private struct Item: Decodable {
        private let id: Int
        private let title: String?
        private let text: String?
        private let by: String
        private let score: Int?
        private let time: Date
        private let descendants: Int?
        private let kids: [Int]?
        private let type: String
        private let url: URL?

        var model: Story {
            Story(
                id: id,
                title: title,
                text: text,
                author: by,
                score: score,
                createdAt: time,
                totalComments: descendants,
                comments: kids,
                type: type,
                url: url
            )
        }
    }
    
    private let client: HTTPClient
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadStory(from url: URL, completion: @escaping (StoryLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                if response.statusCode == 200, let item = try? decoder.decode(Item.self, from: data) {
                    completion(.success(item.model))
                } else {
                    completion(.failure(Error.invalidData))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

final class RemoteStoryDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadStoryFromURL_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://a-given-url.com")!
        
        sut.loadStory(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadStoryFromURLTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://a-given-url.com")!
        
        sut.loadStory(from: url) { _ in }
        sut.loadStory(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadStoryFromURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "a client error", code: 0)
        
        expect(sut, toCompleteWith: .failure(clientError)) {
            client.complete(with: clientError)
        }
    }
    
    func test_loadStoryFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(with: anyData(), statusCode: code, at: index)
            })
        }
    }
    
    func test_loadStoryFromURL_deliversInvalidDataErrorOnNon200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let emptyData = Data()
                client.complete(with: emptyData, statusCode: code, at: index)
            })
        }
    }
    
    func test_loadStoryFromURL_deliversEmptyOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let emptyData = Data()
            
            client.complete(with: emptyData, statusCode: 200)
        })
    }
    
    func test_loadStoryFromURL_deliversReceivedNonEmptyReceivedDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let item = makeItem()
        
        expect(sut, toCompleteWith: .success(item.model), when: {
            client.complete(with: item.data, statusCode: 200)
        })
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteStoryDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteStoryDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func makeItem(id: Int = 0,
                          title: String? = "a title",
                          text: String? = "a text",
                          author: String? = "an author",
                          score: Int? = 0,
                          createdAt: (date: Date, value: Double) = (Date(timeIntervalSince1970: 1175714200), 1175714200),
                          totalComments: Int? = 1,
                          comments: [Int]? = [0],
                          type: String = "a type",
                          url: URL? = URL(string: "https://a-url.com") ) -> (model: Story, data: Data) {
        let item = Story(id: id,
                         title: title,
                         text: text,
                         author: author,
                         score: score,
                         createdAt: createdAt.date,
                         totalComments: totalComments,
                         comments: comments,
                         type: type,
                         url: url)
        let tempJSON: [String: Any?] = [
            "id": id,
            "title": title,
            "text": text,
            "by": author,
            "score": score,
            "time": createdAt.value,
            "descendants": totalComments,
            "kids": comments,
            "type": type,
            "url": url?.absoluteString,
        ]
        let json = tempJSON.compactMapValues { $0 }
        let data = makeItemJSON(json)
        return (item, data)
    }
    
    private func makeItemJSON(_ item: [String: Any]) -> Data {
        try! JSONSerialization.data(withJSONObject: item)
    }
    
    private func anyData() -> Data {
        Data("any data".utf8)
    }
    
    private func failure(_ error: RemoteStoryDataLoader.Error) -> StoryLoader.Result {
        .failure(error)
    }

    private func expect(_ sut: RemoteStoryDataLoader, toCompleteWith expectedResult: StoryLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.loadStory(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        private(set) var requestedURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
            requestedURLs.append(url)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with data: Data, statusCode: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: messages[index].url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
}
