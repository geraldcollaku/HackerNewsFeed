//
//  LoadStoryFromRemoteUseCaseTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 24.03.26.
//

import XCTest
import HackerNewsFeed

final class LoadStoryFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadStoryFromURL_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!

        let (sut, client) = makeSUT(url: url)
        
        sut.loadStory(with: 0) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadStoryFromURLTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.loadStory(with: 0) { _ in }
        sut.loadStory(with: 1) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadStoryFromURL_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "a client error", code: 0)
        
        expect(sut, toCompleteWith: failure(.connectivity)) {
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
    
    func test_loadStoryFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteStoryDataLoader? = RemoteStoryDataLoader(url: anyURL(), client: client)
        
        var capturedResults = [StoryLoader.Result]()
        
        _ = sut?.loadStory(with: 0) {
            capturedResults.append($0)
        }
        
        sut = nil
        
        client.complete(with: anyData(), statusCode: 200)
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    func test_cancelLoadStoryDataTask_cancelsClientURLRequest() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        let task = sut.loadStory(with: 0) { _ in }
        
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")
        
        task.cancel()
        
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
    }
    
    func test_loadStory_doesNotDeliverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        let story = makeItem().data
        
        var received = [StoryLoader.Result]()
        let task = sut.loadStory(with: 0) {
            received.append($0)
        }
        task.cancel()
        
        client.complete(with: anyData(), statusCode: 404)
        
        client.complete(with: story, statusCode: 200)
        client.complete(with: anyNSError())
        
        XCTAssertTrue(received.isEmpty, "Expected no received result after cancelling the task")
    }
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: StoryLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteStoryDataLoader(url: url, client: client)
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
    
    private func failure(_ error: RemoteStoryDataLoader.Error) -> StoryLoader.Result {
        .failure(error)
    }

    private func expect(_ sut: StoryLoader, toCompleteWith expectedResult: StoryLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.loadStory(with: 0) { receivedResult in
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
        private struct Task: HTTPClientTask {
            let callback: () -> Void
            func cancel() {
                callback()
            }
        }
        
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        private(set) var cancelledURLs = [URL]()
        
        private(set) var requestedURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url, completion))
            requestedURLs.append(url)
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
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
