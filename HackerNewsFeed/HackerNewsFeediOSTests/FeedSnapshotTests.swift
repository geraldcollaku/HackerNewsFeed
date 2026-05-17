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
        
        assert(snapshot: sut.snapshot(for: .iPhone17(style: .light)), named: "EMPTY_FEED_light")
        assert(snapshot: sut.snapshot(for: .iPhone17(style: .dark)), named: "EMPTY_FEED_dark")
    }
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone17(style: .light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone17(style: .dark)), named: "FEED_WITH_CONTENT_dark")
    }
    
    func test_feedWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error(message: "This is a \nmulti-line\nerror message"))
        
        assert(snapshot: sut.snapshot(for: .iPhone17(style: .light)), named: "FEED_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone17(style: .dark)), named: "FEED_WITH_ERROR_MESSAGE_dark")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()

        sut.display(feedWithFailedStoryLoading())

        assert(snapshot: sut.snapshot(for: .iPhone17(style: .light)), named: "FEED_WITH_FAILED_STORY_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone17(style: .dark)), named: "FEED_WITH_FAILED_STORY_LOADING_dark")
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
    
    private func assert(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting", file: file, line: line)
            return
        }
        
        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)
            
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot  does not match the stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
        
    }
    
    private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
    
    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
    
    private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        return data
    }
}

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone17(style: .light)
    
    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        let dummyScene = (UIWindowScene.self as NSObject.Type).init() as! UIWindowScene
        self.init(windowScene: dummyScene)
        self.frame = CGRect(origin: .zero, size: configuration.size)
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargings
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargings
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        configuration.safeAreaInsets
    }
    
    override var traitCollection: UITraitCollection {
        return configuration.traitCollection
    }
    
    func snapshot() -> UIImage {
        let render = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: configuration.traitCollection))
        return render.image { action in
            layer.render(in: action.cgContext)
        }
    }
}

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargings: UIEdgeInsets
    let traitCollection: UITraitCollection
    
    static func iPhone17(style: UIUserInterfaceStyle, contentSize: UIContentSizeCategory = .medium) -> SnapshotConfiguration {
        SnapshotConfiguration(
            size: CGSize(width: 393, height: 852),
            safeAreaInsets: UIEdgeInsets(top: 62, left: 0, bottom: 34, right: 0),
            layoutMargings: UIEdgeInsets(top: 70, left: 8, bottom: 42, right: 8),
            traitCollection: UITraitCollection(mutations: { traits in
                traits.forceTouchCapability = .unavailable
                traits.layoutDirection = .leftToRight
                traits.preferredContentSizeCategory = contentSize
                traits.userInterfaceIdiom = .phone
                traits.verticalSizeClass = .regular
                traits.displayScale = 3
                traits.displayGamut = .P3
                traits.userInterfaceStyle = style
            })
        )
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
        controller?.display(shouldRetry ? ResourceErrorViewModel.error(message: "error") : .noError)
    }
    
    func didCancelStoryRequest() {}
}
