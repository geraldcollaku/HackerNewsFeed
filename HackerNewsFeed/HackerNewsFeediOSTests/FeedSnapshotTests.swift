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
    
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        record(snapshot: sut.snapshot(), named: "EMPTY_FEED")
    }
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        record(snapshot: sut.snapshot(), named: "FEED_WITH_CONTENT")
    }
    
    func test_feedWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error(message: "This is a \nmulti-line\nerror message"))
        
        record(snapshot: sut.snapshot(), named: "FEED_WITH_ERROR_MESSAGE")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithFailedStoryLoading())
        
        record(snapshot: sut.snapshot(), named: "FEED_WITH_FAILED_STORY_LOADING")
    }
    
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    private func emptyFeed() -> [FeedStoryCellController] {
        return []
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
    
    private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return
        }
        
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
}

extension UIViewController {
    func snapshot() -> UIImage {
        let render = UIGraphicsImageRenderer(bounds: view.bounds)
        return render.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}

private extension FeedViewController {
    func display(_ stubs: [StoryStub]) {
        let cells: [FeedStoryCellController] = stubs.map { stub in
            let cellController = FeedStoryCellController(delegate: stub)
            stub.controller = cellController
            return cellController
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
        controller?.display(FeedStoryErrorViewModel(errorMessage: shouldRetry ? "error" : nil))
    }
    
    func didCancelStoryRequest() {}
}
