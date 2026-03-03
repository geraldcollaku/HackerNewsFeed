//
//  FeedViewControllerTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 27.02.26.
//

import XCTest
import HackerNewsFeed
import HackerNewsFeediOS

final class FeedViewControllerTests: XCTestCase {
        
    func test_loadFeedActions_loadsFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedIdCallCount, 0, "Expected no loading indicator before view is loaded")
        
        sut.simulateApperance()
        XCTAssertEqual(loader.loadFeedIdCallCount, 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedIdCallCount, 2, "Expected another loading request once view is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedIdCallCount, 3, "Expected a third loading request once view is loaded")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.simulateApperance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
 
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")

        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once the user initiated a reload")

        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user intiated loading is completed")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let (sut, loader) = makeSUT()

        sut.simulateApperance()
        XCTAssertEqual(sut.numberOfRenderedViews(), 0)
        
        loader.completeFeedLoading(with: [makeFeedId()], at: 0)
        XCTAssertEqual(sut.numberOfRenderedViews(), 1)
    }
    
    func test_storyView_loadsStoriesWhenVisible() {
        let story0 = 0
        let story1 = 1

        let (sut, loader) = makeSUT()

        sut.simulateApperance()
        loader.completeFeedLoading(with: [makeFeedId(id: story0), makeFeedId(id: story1)], at: 0)
        
        XCTAssertEqual(loader.loadedStoriesIds, [], "Expected no stories until view becomes visible")
        
        sut.simulateStoryViewVisible(at: 0)
        XCTAssertEqual(loader.loadedStoriesIds, [story0], "Expected first story once view becomes visible")
    
        sut.simulateStoryViewVisible(at: 1)
        XCTAssertEqual(loader.loadedStoriesIds, [story0, story1], "Expected a second story once second view becomes visible")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader, storyLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeFeedId(id: Int = Int.random(in: 0 ... 100)) -> FeedId {
        FeedId(id: id)
    }
    
    class LoaderSpy: FeedLoader, StoryLoader {
        private var feedIdRequests = [(FeedLoader.Result) -> Void]()
        
        var loadFeedIdCallCount: Int {
            return feedIdRequests.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedIdRequests.append(completion)
        }
        
        func completeFeedLoading(with news: [FeedId] = [], at index: Int = 0) {
            feedIdRequests[index](.success(news))
        }
        
        // MARK: - StoryLoader
        
        private(set) var loadedStoriesIds = [Int]()
        
        func loadStory(with id: Int) {
            loadedStoriesIds.append(id)
        }
    }
}

private extension FeedViewController {
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateStoryViewVisible(at index: Int) {
        _ = storyView(at: index)
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedViews() -> Int {
        tableView.numberOfRows(inSection: feedSection)
    }
    
    func storyView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var feedSection: Int { 0 }
    
    func simulateApperance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            replaceRefreshControlWithFakeForiOS17Support()
        }
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func replaceRefreshControlWithFakeForiOS17Support() {
        let fake = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = fake
    }
}

private class FakeRefreshControl: UIRefreshControl {
    private var _isRefreshing = false
    
    override var isRefreshing: Bool { _isRefreshing }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
