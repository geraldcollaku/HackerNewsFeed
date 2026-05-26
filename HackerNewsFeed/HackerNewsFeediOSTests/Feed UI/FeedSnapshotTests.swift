//
//  FeedSnapshotTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.04.26.
//

import XCTest
import HackerNewsFeediOS
@testable import HackerNewsFeed

class FeedSnapshotTests: XCTestCase {
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone17(style: .light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone17(style: .dark)), named: "FEED_WITH_CONTENT_dark")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()

        sut.display(feedWithFailedStoryLoading())

        assert(snapshot: sut.snapshot(for: .iPhone17(style: .light)), named: "FEED_WITH_FAILED_STORY_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone17(style: .dark)), named: "FEED_WITH_FAILED_STORY_LOADING_dark")
    }
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    private func feedWithContent() -> [StoryStub] {
        return [
            StoryStub(
                author: "John Doe",
                title: "Ask HN: What are the best resources for learning Swift?",
                score: "342",
                url: "news.ycombinator.com",
                shouldRetry: false
            ),
            StoryStub(
                author: "Jane Smith",
                title: "Show HN: I built an open source Hacker News client for iOS",
                score: "89",
                url: "github.com/janesmith/hn-ios",
                shouldRetry: false
            )
        ]
    }
    
    private func feedWithFailedStoryLoading() -> [StoryStub] {
        return [
            StoryStub(
                author: nil,
                title: nil,
                score: nil,
                url: nil,
                shouldRetry: true
            ),
            StoryStub(
                author: "Jane Smith",
                title: "Show HN: I built an open source Hacker News client for iOS",
                score: "89",
                url: "github.com/janesmith/hn-ios",
                shouldRetry: true
            )
        ]
    }
}

private extension ListViewController {
    func display(_ stubs: [StoryStub]) {
        let cells: [CellController] = stubs.map { stub in
            let cellController = FeedStoryCellController(delegate: stub)
            stub.controller = cellController
            return CellController(cellController)
        }
        display(cells)
    }
 }

private class StoryStub: FeedStoryCellControllerDelegate {
    weak var controller: FeedStoryCellController?
    let viewModel: FeedStoryViewModel
    let shouldRetry: Bool
    
    init(author: String?, title: String?, score: String?, url: String?, shouldRetry: Bool) {
        self.viewModel = FeedStoryViewModel(
            author: author,
            title: title,
            score: score,
            url: url
        )
        self.shouldRetry = shouldRetry
    }
    
    func didRequestStory() {
        controller?.display(viewModel)
        controller?.display(shouldRetry ? ResourceErrorViewModel.error(message: "error") : .noError)
    }
    
    func didCancelStoryRequest() {}
}
