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
    
    func test_storyView_cancelsStoryLoadingWhenViewIsNotVisibleAnymore() {
        let story0 = 0
        let story1 = 1

        let (sut, loader) = makeSUT()

        sut.simulateApperance()
        loader.completeFeedLoading(with: [makeFeedId(id: story0), makeFeedId(id: story1)], at: 0)
        XCTAssertEqual(loader.cancelledStoriesIds, [], "Expected no cancelled story until view is not visible")
        
        sut.simulateStoryViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledStoriesIds, [story0], "Expected one cancelled story request once view is not visible anymore")
    
        sut.simulateStoryViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledStoriesIds, [story0, story1], "Expected two cancelled story request once view is not visible anymore")
    }
    
    func test_storyViewLoadingIndicator_isVisibleWhenLoadingStory() {
        let story0 = 0
        let story1 = 1
        let (sut, loader) = makeSUT()
        
        sut.simulateApperance()
        loader.completeFeedLoading(with: [makeFeedId(id: story0), makeFeedId(id: story1)], at: 0)
        
        let view0 = sut.simulateStoryViewVisible(at: 0)
        let view1 = sut.simulateStoryViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, true, "Expected loading indicator for first view while loading first story")
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true, "Expected loading indicator for second view while loading second story")
        
        loader.completeStoryLoading(at: 0)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false, "Expected no loading indicator for first view once first story loading completes successfully")
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true, "Expected no loading indicator state change once first story loading completes succesfully")
        
        loader.completeStoryLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false, "Expected no loading indicator change for first view once second story loading completes successfully")
        XCTAssertEqual(view1?.isShowingLoadingIndicator, false, "Expected no loading indicator state change once seconds story loading completes succesfully")
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
        
        private struct StoryLoaderTaskSpy: StoryLoaderTask {
            var cancelCallback: () -> Void
            
            func cancel() {
                cancelCallback()
            }
        }
        
        private var storiesRequests = [(id: Int, completion: (StoryLoader.Result) -> Void)]()
        
        var loadedStoriesIds: [Int] {
            storiesRequests.map { $0.id }
        }
        
        private(set) var cancelledStoriesIds = [Int]()
        
        func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
            storiesRequests.append((id, completion))
            return StoryLoaderTaskSpy { [weak self] in
                self?.cancelledStoriesIds.append(id)
            }
        }
        
        func completeStoryLoading(with story: Story = .any, at index: Int = 0) {
            storiesRequests[index].completion(.success(story))
        }
        
        func completeStoryLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            storiesRequests[index].completion(.failure(error))
        }
    }
}

extension Story {
    static var any = Story(
        id: Int.random(in: 0 ... 100),
        title: "a title",
        text: "a text",
        author: "a username",
        score: 10,
        createdAt: Date(),
        totalComments: 5,
        comments: [1, 2, 3],
        type: "story",
        url: URL(string: "https://any-url.com")!
    )
}

private extension FeedViewController {
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateStoryViewNotVisible(at row: Int) {
        let view = simulateStoryViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    }
    
    @discardableResult
    func simulateStoryViewVisible(at index: Int) -> FeedStoryCell? {
        return storyView(at: index) as? FeedStoryCell
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

extension FeedStoryCell {
    var isShowingLoadingIndicator: Bool {
        container.isShimmering
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
