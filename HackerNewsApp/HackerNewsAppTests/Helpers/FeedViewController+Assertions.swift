//
//  FeedViewController+Assertions.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 09.04.26.
//

import XCTest
import HackerNewsFeediOS
import HackerNewsFeed

extension FeedUIIntegrationTests {
    func assertThat(_ sut: ListViewController, isRendering feed: [FeedId], file: StaticString = #file, line: UInt = #line) {
        sut.tableView.layoutIfNeeded()
        RunLoop.main.run(until: Date())
        
        guard sut.numberOfRenderedViews() == feed.count else {
            return XCTFail("Expected \(feed.count) stories, got \(sut.numberOfRenderedViews()) instead", file: file, line: line)
        }
        
        RunLoop.main.run(until: Date() + 1)
    }
}
