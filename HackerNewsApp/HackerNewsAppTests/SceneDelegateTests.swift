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
    func test_configureWindow_setsWindowAsKeyAndVisible() throws {
        let sut = SceneDelegate()
        let scene = try XCTUnwrap((UIWindowScene.self as NSObject.Type).init() as? UIWindowScene)
        let window = UIWindowSpy(windowScene: scene)
        window.traitOverrides.userInterfaceIdiom = .phone
        sut.window = window

        sut.configureWindow()
        
        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1, "Expected to make window key and visible")
    }
    
    func test_configureWindow_configuresRootViewController() throws {
        let sut = SceneDelegate()

        let scene = try XCTUnwrap((UIWindowScene.self as NSObject.Type).init() as? UIWindowScene)
        let window = UIWindow(windowScene: scene)
        window.traitOverrides.userInterfaceIdiom = .phone
        sut.window = window

        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
        XCTAssertTrue(topController is FeedViewController, "Expected a feed controller at top view controller, got \(String(describing: topController)) instead")
    }
    
    private class UIWindowSpy: UIWindow {
        private(set) var makeKeyAndVisibleCallCount = 0
        
        override func makeKeyAndVisible() {
            makeKeyAndVisibleCallCount += 1
        }
    }
}
