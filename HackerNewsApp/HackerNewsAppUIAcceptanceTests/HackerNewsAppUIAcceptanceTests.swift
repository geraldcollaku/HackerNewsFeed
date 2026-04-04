//
//  HackerNewsAppUIAcceptanceTests.swift
//  HackerNewsAppUIAcceptanceTests
//
//  Created by Gerald Collaku on 04.04.26.
//

import XCTest

final class HackerNewsAppUIAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        app.launchArguments = ["-reset", "-connectivity", "online"]
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "feed-story-cell")
        XCTAssertEqual(feedCells.count, 2)
    }
    
    func test_onLaunch_displaysCachedFeedWhenCustomerHasNoConnectivity() {
        let onlineApp = XCUIApplication()
        onlineApp.launchArguments = ["-reset", "-connectivity", "online"]
        onlineApp.launch()
        
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()
        
        let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-story-cell")
        XCTAssertEqual(cachedFeedCells.count, 2)
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let app = XCUIApplication()
        app.launchArguments = ["-reset", "-connectivity", "offline"]
        app.launch()
        
        let cachedFeedCells = app.cells.matching(identifier: "feed-story-cell")
        XCTAssertEqual(cachedFeedCells.count, 0)
    }
}
