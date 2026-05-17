//
//  FeedStoryPresenterTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 22.03.26.
//

import XCTest
import HackerNewsFeed

final class FeedStoryPresenterTests: XCTestCase {
    
    func test_map_createsViewModel() {
        let story = Story(
            id: 1,
            title: "a title",
            text: nil,
            author: "an author",
            score: 42,
            createdAt: Date(),
            totalComments: 0,
            comments: nil,
            type: "story",
            url: URL(string: "https://any-url.com")!)

        let viewModel = FeedStoryPresenter.map(story)

        XCTAssertEqual(viewModel.author, "an author")
        XCTAssertEqual(viewModel.title, "a title")
        XCTAssertEqual(viewModel.score, "42")
        XCTAssertEqual(viewModel.url, "https://any-url.com")
    }
}
