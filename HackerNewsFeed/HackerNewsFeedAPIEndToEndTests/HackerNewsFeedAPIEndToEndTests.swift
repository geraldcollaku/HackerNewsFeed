//
//  HackerNewsFeedAPIEndToEndTests.swift
//  HackerNewsFeedAPIEndToEndTests
//
//  Created by Gerald Collaku on 29.12.25.
//

import XCTest
import HackerNewsFeed

final class HackerNewsFeedAPIEndToEndTests: XCTestCase {
    
    func test_endToEndTestGetFeedResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(feed)?:
            XCTAssertEqual(feed.count, 7, "Expected 7 items in the test account")
            
            XCTAssertEqual(feed[0], expectedId(at: 0))
            XCTAssertEqual(feed[1], expectedId(at: 1))
            XCTAssertEqual(feed[2], expectedId(at: 2))
            XCTAssertEqual(feed[3], expectedId(at: 3))
            XCTAssertEqual(feed[4], expectedId(at: 4))
            XCTAssertEqual(feed[5], expectedId(at: 5))
            XCTAssertEqual(feed[6], expectedId(at: 6))
            
        case let .failure(error):
            XCTFail("Expected successful feed result, got \(error) instead")
        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }
    
    func test_endToEndTestServerGETStoryResult_MatchesFixedTestData() {
        switch getStoryDataResult() {
        case let .success(story):
            XCTAssertEqual(story, expectedStory())
        case let .failure(error)?:
            XCTFail("Expected successful story result, got \(error) instead")
        default:
            XCTFail("Expected successful story result, got no result instead")
        }
    }
    
    // MARK: - Helpers
    
    private func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> FeedLoader.Result? {
        let url = feedTestServerURL.appendingPathComponent("items.json")
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)

        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: FeedLoader.Result?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
        
        return receivedResult
    }
    
    private func getStoryDataResult(file: StaticString = #file, line: UInt = #line) -> StoryLoader.Result? {
        let id = 46383452
        let url = feedTestServerURL.appendingPathComponent("item/\(id).json")
        
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteStoryDataLoader(url: url, client: client)
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(loader)
        
        let exp = expectation(description: "Wait for load completion")
        var receivedResult: StoryLoader.Result?
        _ = loader.loadStory(with: id) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return receivedResult
    }
    
    private var feedTestServerURL: URL {
        URL(string: "https://hackernews-fa652-default-rtdb.europe-west1.firebasedatabase.app")!
    }
    
    private func expectedId(at index: Int) -> FeedId {
        FeedId(id: id(at: index))
    }
    
    private func id(at index: Int) -> Int {
        return [
            46383452,
            46391572,
            46385197,
            46380168,
            46414570,
            46413685,
            46412006
        ][index]
    }
    
    private func expectedStory() -> Story {
        Story(id: 46383452,
              title: "Gerald is hacking",
              text: nil,
              author: "gerald",
              score: 2,
              createdAt: Date(timeIntervalSince1970: 1772959850),
              totalComments: 0,
              comments: nil,
              type: "story",
              url: URL(string: "https://www.msn.com/en-us/news/insight/blackrock-caps-exits-as-redemptions-surge/gm-GM1184A108")!)
    }
}
