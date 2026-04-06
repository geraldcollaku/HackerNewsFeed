//
//  FeedSnapshotTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.04.26.
//

import XCTest
import HackerNewsFeediOS
import HackerNewsFeed

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
                url: "news.ycombinator.com"
            ),
            StoryStub(
                author: "Jane Smith",
                title: "Show HN: I built an open source Hacker News client for iOS",
                score: "89",
                url: "github.com/janesmith/hn-ios"
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
    
    init(author: String?, title: String?, score: String?, url: String?) {
        self.viewModel = FeedStoryViewModel(
            author: author,
            title: title,
            score: score,
            url: url
        )
    }
    
    func didRequestStory() {
        controller?.display(viewModel)
    }
    
    func didCancelStoryRequest() {}
}
