//
//  HackerNewsFeedAPIEndToEndTests.swift
//  HackerNewsFeedAPIEndToEndTests
//
//  Created by Gerald Collaku on 29.12.25.
//

import XCTest
import HackerNewsFeed

final class HackerNewsFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestGetFeedResult_deliversStoriesOnSuccess() {
        switch getFeedResult() {
        case let .success(feed)?:
            XCTAssertFalse(feed.isEmpty, "Expected at least one story in the feed")
            feed.forEach { XCTAssertNotNil($0.id, "Expected valid story id") }

        case let .failure(error):
            XCTFail("Expected successful feed result, got \(error) instead")
        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }

    func test_endToEndTestServerGETStoryResult_deliversStoryOnSuccess() {
        guard let firstId = firstFeedId() else {
            return XCTFail("Expected at least one story id from feed")
        }

        switch getStoryDataResult(id: firstId) {
        case let .success(story):
            XCTAssertEqual(story.id, firstId)
            XCTAssertNotNil(story.title)
            XCTAssertNotNil(story.author)

        case let .failure(error)?:
            XCTFail("Expected successful story result, got \(error) instead")
        default:
            XCTFail("Expected successful story result, got no result instead")
        }
    }

    override func setUp() {
        super.setUp()
        warmUpServer()
    }

    // MARK: - Helpers

    private func warmUpServer() {
        let url = URL(string: "http://localhost:3000/health")!
        let exp = expectation(description: "Warm up server")
        URLSession.shared.dataTask(with: url) { _, _, _ in exp.fulfill() }.resume()
        wait(for: [exp], timeout: 60.0)
    }

    private func firstFeedId() -> Int? {
        if case let .success(feed)? = getFeedResult() {
            return feed.first?.id
        }
        return nil
    }

    private func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> Swift.Result<[FeedId], Error>? {
        let url = feedTestServerURL
            .appendingPathComponent("newstories")
            .appending(queryItems: [URLQueryItem(name: "page", value: "1")])
        let client = ephemeralClient()
        
        let exp = expectation(description: "Wait for load completion")
        var receivedResult: Swift.Result<[FeedId], Error>?
        client.get(from: url) { result in
            receivedResult = result.flatMap { (data, response) in
                do {
                    return .success(try FeedItemsMapper.map(data, from: response))
                } catch {
                    return .failure(error)
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 60.0)
        return receivedResult
    }

    private func getStoryDataResult(id: Int, file: StaticString = #file, line: UInt = #line) -> StoryLoader.Result? {
        let url = feedTestServerURL.appendingPathComponent("item/\(id)")
        let client = ephemeralClient()
        let loader = RemoteStoryDataLoader(url: { _ in url }, client: client)
        trackForMemoryLeaks(loader)

        let exp = expectation(description: "Wait for load completion")
        var receivedResult: StoryLoader.Result?
        _ = loader.loadStory(with: id) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 60.0)
        return receivedResult
    }
    
    private func ephemeralClient(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackForMemoryLeaks(client, file: file, line: line)
        return client
    }

    private var feedTestServerURL: URL {
        URL(string: "http://localhost:3000/v0")!
    }
}
