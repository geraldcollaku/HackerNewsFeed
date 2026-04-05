//
//  FeedAcceptanceTests.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 05.04.26.
//


import XCTest
import HackerNewsFeed
import HackerNewsFeediOS
@testable import HackerNewsApp

final class FeedAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() throws {
        let feed = try launch(httpClient: HTTPClientStub.online(response), store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedViews(), 2)
        XCTAssertNotNil(feed.renderedStoryAuthor(at: 0))
        XCTAssertNotNil(feed.renderedStoryTitle(at: 0))
        XCTAssertNotNil(feed.renderedStoryAuthor(at: 1))
        XCTAssertNotNil(feed.renderedStoryTitle(at: 1))
    }
    
    func test_onLaunch_displaysCachedFeedWhenCustomerHasNoConnectivity() throws {
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = try launch(httpClient: .online(response), store: sharedStore)
        onlineFeed.simulateStoryViewVisible(at: 0)
        onlineFeed.simulateStoryViewVisible(at: 1)
        
        let offlineFeed = try launch(httpClient: .offline, store: sharedStore)
        
        XCTAssertEqual(offlineFeed.numberOfRenderedViews(), 2)
        XCTAssertNotNil(offlineFeed.renderedStoryAuthor(at: 0))
        XCTAssertNotNil(offlineFeed.renderedStoryTitle(at: 0))
        XCTAssertNotNil(offlineFeed.renderedStoryAuthor(at: 1))
        XCTAssertNotNil(offlineFeed.renderedStoryTitle(at: 1))
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
       
    }
    
    // MARK: - Helpers
    
    private func launch(
        httpClient: HTTPClientStub = .offline,
        store: InMemoryFeedStore = .empty) throws -> FeedViewController {
            let store = InMemoryFeedStore.empty
            let httpClient = HTTPClientStub.online(response)
            let sut = SceneDelegate(httpClient: httpClient, store: store)
            let dummyScene = try XCTUnwrap((UIWindowScene.self as NSObject.Type).init() as? UIWindowScene)
            sut.window = UIWindow(windowScene: dummyScene)
            sut.window?.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
            
            sut.configureWindow()
            
            let nav = sut.window?.rootViewController as? UINavigationController
            let feed = nav?.topViewController as! FeedViewController
            feed.simulateApperance()
            
            return feed
    }
    
    private class HTTPClientStub: HTTPClient {
        private class Task: HTTPClientTask {
            func cancel() {}
        }
        
        private let stub: (URL) -> HTTPClient.Result
        
        init(stub: @escaping (URL) -> HTTPClient.Result) {
            self.stub = stub
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            completion(stub(url))
            return Task()
        }
        
        static var offline: HTTPClientStub {
            HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0))})
        }
        
        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub { url in .success(stub(url))}
        }
    }
    
    private class InMemoryFeedStore: FeedStore, StoryStore {
        private var feedCache: CachedFeed?
        private var storyCache: [Int: LocalStory] = [:]
        
        func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
            feedCache = nil
            completion(.success(()))
        }
        
        func insert(_ feed: [LocalFeedId], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
            feedCache =  CachedFeed(feed: feed, timestamp: timestamp)
            completion(.success(()))
        }
        
        func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
            completion(.success(feedCache))
        }
        
        func insert(_ story: LocalStory, completion: @escaping (StoryStore.InsertionResult) -> Void) {
            storyCache[story.id] = story
            completion(.success(()))
        }
        
        func retrieve(for id: Int, completion: @escaping (StoryStore.RetrievalResult) -> Void) {
            let story = storyCache[id]
            completion(.success((story)))
        }
        
        static var empty: InMemoryFeedStore {
            InMemoryFeedStore()
        }
    }
    
    
    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "https://hacker-news.firebaseio.com/v0/newstories.json":
            return makeFeedIdData()
        default:
            return makeStoryData()
        }
    }
    
    private func makeFeedIdData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [1, 2])
    }
    
    private func makeStoryData() -> Data {
        let story: [String: Any] = [
            "id": 1,
            "title": "a title",
            "by": "an author",
            "score": 10,
            "time": 1000,
            "descendants": 0,
            "type": "story",
            "url": "https://a-url.com"
        ]
        return try! JSONSerialization.data(withJSONObject: story)
    }
}
