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
        XCTAssertTrue(feed.canLoadMoreFeed)
        
        feed.simulateLoadMoreFeedAction()
        
        XCTAssertEqual(feed.numberOfRenderedViews(), 3)
        XCTAssertNotNil(feed.renderedStoryAuthor(at: 0))
        XCTAssertNotNil(feed.renderedStoryTitle(at: 0))
        XCTAssertNotNil(feed.renderedStoryAuthor(at: 1))
        XCTAssertNotNil(feed.renderedStoryTitle(at: 1))
        XCTAssertNotNil(feed.renderedStoryAuthor(at: 2))
        XCTAssertNotNil(feed.renderedStoryTitle(at: 2))
        XCTAssertTrue(feed.canLoadMoreFeed)
        
        feed.simulateLoadMoreFeedAction()
        
        XCTAssertEqual(feed.numberOfRenderedViews(), 3)
        XCTAssertNotNil(feed.renderedStoryAuthor(at: 0))
        XCTAssertNotNil(feed.renderedStoryTitle(at: 0))
        XCTAssertNotNil(feed.renderedStoryAuthor(at: 1))
        XCTAssertNotNil(feed.renderedStoryTitle(at: 1))
        XCTAssertNotNil(feed.renderedStoryAuthor(at: 2))
        XCTAssertNotNil(feed.renderedStoryTitle(at: 2))
        XCTAssertFalse(feed.canLoadMoreFeed)
    }
    
    func test_onLaunch_displaysCachedFeedWhenCustomerHasNoConnectivity() throws {
        let sharedStore = try CoreDataFeedStore.empty
        let onlineFeed = try launch(httpClient: .online(response), store: sharedStore)
        onlineFeed.simulateStoryViewVisible(at: 0)
        onlineFeed.simulateStoryViewVisible(at: 1)
        onlineFeed.simulateLoadMoreFeedAction()
        onlineFeed.simulateStoryViewVisible(at: 2)
        
        let offlineFeed = try launch(httpClient: .offline, store: sharedStore)
        
        XCTAssertEqual(offlineFeed.numberOfRenderedViews(), 3)
        XCTAssertNotNil(offlineFeed.renderedStoryAuthor(at: 0))
        XCTAssertNotNil(offlineFeed.renderedStoryTitle(at: 0))
        XCTAssertNotNil(offlineFeed.renderedStoryAuthor(at: 1))
        XCTAssertNotNil(offlineFeed.renderedStoryTitle(at: 1))
        XCTAssertNotNil(offlineFeed.renderedStoryAuthor(at: 2))
        XCTAssertNotNil(offlineFeed.renderedStoryTitle(at: 2))
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() throws {
        let feed = try launch(httpClient: .offline, store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedViews(), 0)
    }
    
    func test_onEnteringBackground_deletesExpiredCache() throws {
        let store = try CoreDataFeedStore.withExpiredCache
        
        enterBackground(with: store)
        
        XCTAssertNil(try store.retrieve())
    }
    
    func test_onEnteringBackground_keepsNonExpiredCache() throws {
        let store = try CoreDataFeedStore.withNonExpiredCache
        
        enterBackground(with: store)
        
        XCTAssertNotNil(try store.retrieve())
    }
    
    func test_onFeedItemSelection_displaysComments() throws {
        let comments = try showCommentsForFirstItem()
        
        XCTAssertEqual(comments.numberOfRenderedComments(), 1)
        XCTAssertEqual(comments.commentMessage(at: 0), makeCommentMessage())
    }
    
    // MARK: - Helpers
    
    private func launch(httpClient: HTTPClientStub = .offline,
                        store: CoreDataFeedStore) throws -> ListViewController {
            let sut = SceneDelegate(scheduler: DispatchQueue.immediateWhenOnMainQueueScheduler, httpClient: httpClient, store: store)
            let dummyScene = try XCTUnwrap((UIWindowScene.self as NSObject.Type).init() as? UIWindowScene)
            sut.window = UIWindow(windowScene: dummyScene)
            sut.window?.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
            
            sut.configureWindow()
            
            let nav = sut.window?.rootViewController as? UINavigationController
            let feed = nav?.topViewController as! ListViewController
            feed.simulateApperance()
            
            return feed
    }
    
    private func enterBackground(with store: CoreDataFeedStore) {
        let sut = SceneDelegate(scheduler: DispatchQueue.immediateWhenOnMainQueueScheduler, httpClient: HTTPClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }
    
    private func showCommentsForFirstItem() throws -> ListViewController {
        let feed = try launch(httpClient: HTTPClientStub.online(response), store: .empty)

        feed.simulateTapOnFeedItem(at: 0)

        let nav = feed.navigationController
        let comments = nav?.topViewController as! ListViewController
        comments.simulateApperance()
        
        RunLoop.current.run(until: Date())
        
        return comments
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
    
    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.lastPathComponent {
        case "newstories" where url.query?.contains("after_id") == false:
            return makeFirstFeedIdPageData()
        case "newstories" where url.query?.contains("after_id=2") == true:
            return makeSecondFeedIdPageData()
        case "newstories" where url.query?.contains("after_id=3") == true:
            return makeEmptyFeedIdPageData()
        case "comments":
            return makeCommentsData()
        default:
            return makeStoryData(for: url)
        }
    }

    private func makeFirstFeedIdPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["ids": [1, 2]])
    }
    
    private func makeSecondFeedIdPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["ids": [3]])
    }
    
    private func makeEmptyFeedIdPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["ids": []])
    }
    
    private func makeStoryData(for url: URL) -> Data {
        let id = Int(url.lastPathComponent.replacingOccurrences(of: ".json", with: "")) ?? 1
        let story: [String: Any] = [
            "id": id,
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
    
    private func makeCommentsData() -> Data {
        let comments: [[String: Any]] = [
            [
                "id": 1,
                "message": makeCommentMessage(),
                "created_at": "2026-05-30T10:00:00.000Z",
                "author": ["username": "a username"]
            ]
        ]
        return try! JSONSerialization.data(withJSONObject: comments)
    }
    
    private func makeCommentMessage() -> String { "a message" }
}

extension CoreDataFeedStore {
    
    static var empty: CoreDataFeedStore {
        get throws {
            try CoreDataFeedStore(storeURL: URL(fileURLWithPath: "/dev/null"), contextQueue: .main)
        }
    }
    
    static var withExpiredCache: CoreDataFeedStore {
        get throws {
            let store = try CoreDataFeedStore.empty
            try store.insert([], timestamp: Date.distantPast)
            return store
        }
    }
    
    static var withNonExpiredCache: CoreDataFeedStore {
        get throws {
            let store = try CoreDataFeedStore.empty
            try store.insert([], timestamp: Date())
            return store
        }
    }
}
