//
//  FeedCommentsSnapshotTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 19.05.26.
//

import XCTest
import HackerNewsFeed
import HackerNewsFeediOS

class FeedCommentsSnapshotTests: XCTestCase {

    func test_listWithComments() {
        let sut = makeSUT()
        
        sut.display(comments())
        
        assert(snapshot: sut.snapshot(for: .iPhone17(style: .light)), named: "FEED_COMMENTS_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone17(style: .dark)), named: "FEED_COMMENTS_WITH_CONTENT_dark")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "FeedComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    private func comments() -> [CellController] {
        commentControllers().map {
            CellController($0)
        }
    }
    
    private func commentControllers() -> [FeedCommentCellController] {
        return [
            FeedCommentCellController(
                model: FeedCommentViewModel(
                    message: "Ask HN: What are the best resources for learning Swift?",
                    date: "1000 years ago",
                    username: "a long long long username")
            ),
            FeedCommentCellController(
                model: FeedCommentViewModel(
                    message: "Show HN: I built an open source Hacker News client for iO",
                    date: "10 days ago",
                    username: "a username")
            ),
            FeedCommentCellController(
                model: FeedCommentViewModel(
                    message: "nice",
                    date: "1 hour ago",
                    username: "a.")
            )
        ]
    }
}
