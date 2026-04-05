//
//  SceneDelegateTests.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 05.04.26.
//

import XCTest
import HackerNewsFeediOS
@testable import HackerNewsApp

class SceneDelegateTests: XCTestCase {
    
    func test_sceneWillConnectToSession_configuresRootViewController() throws {
        let sut = SceneDelegate()
        
        let scene = try XCTUnwrap((UIWindowScene.self as NSObject.Type).init() as? UIWindowScene)
        sut.window = UIWindow(windowScene: scene)
        
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
        XCTAssertTrue(topController is FeedViewController, "Expected a feed controller at top view controller, got \(String(describing: topController)) instead")
    }
}
