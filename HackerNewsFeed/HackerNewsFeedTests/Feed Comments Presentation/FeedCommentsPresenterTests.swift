//
//  FeedCommentsPresenterTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 17.05.26.
//

import XCTest
import HackerNewsFeed

class FeedCommentsPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(FeedCommentsPresenter.title, localized("FEED_COMMENTS_VIEW_TITLE"))
    }
    
    func test_map_createsViewModels() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        let comments = [
            FeedComment(
                id: 0,
                message: "a message",
                createdAt: now.adding(minutes: -5),
                username: "a username"),
            FeedComment(
                id: 0,
                message: "another message",
                createdAt: now.adding(days: -1),
                username: "another username")
        ]
        let viewModel = FeedCommentsPresenter.map(
            comments,
            currentDate: now,
            calendar: calendar,
            locale: locale
        )
        
        XCTAssertEqual(viewModel.comments, [
            FeedCommentViewModel(
                message: "a message",
                date: "5 minutes ago",
                username: "a username"
            ),
            FeedCommentViewModel(
                message: "another message",
                date: "1 day ago",
                username: "another username"
            )
        ])
    }
    
    // MARK: - Helpers

    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "FeedComments"
        let bundle = Bundle(for: FeedCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
