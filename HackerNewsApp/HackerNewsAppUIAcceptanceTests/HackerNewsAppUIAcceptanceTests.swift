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
        
        app.launch()
        
        XCTAssertEqual(app.cells.count, 500)
    }
}
