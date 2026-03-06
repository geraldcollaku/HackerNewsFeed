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
        
        XCTAssertEqual(loader.storiesRequests.count, 0, "Expected no stories until view becomes visible")
        
        sut.simulateStoryViewVisible(at: 0)
        XCTAssertEqual(loader.storiesRequests.count, 1, "Expected first story once view becomes visible")
        
        sut.simulateStoryViewVisible(at: 1)
        XCTAssertEqual(loader.storiesRequests.count, 2, "Expected a second story once second view becomes visible")
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
    
    func test_storyView_rendersStory() {
        let (sut, loader) = makeSUT()
        let story0 = makeStory(title: "a title", author: "an author")
        let story1 = makeStory(title: "another title", author: "another author")
        
        sut.simulateApperance()
        loader.completeFeedLoading(with: [makeFeedId(), makeFeedId()], at: 0)
        
        let view0 = sut.simulateStoryViewVisible(at: 0)
        let view1 = sut.simulateStoryViewVisible(at: 1)
        
        loader.completeStoryLoading(with: story0, at: 0)
        XCTAssertEqual(view0?.titleText, story0.title)
        XCTAssertEqual(view0?.urlText, story0.url?.absoluteString)
        XCTAssertEqual(view0?.authorText, story0.author)
        XCTAssertEqual(view0?.scoreText, String(story0.score ?? 0))
        
        loader.completeStoryLoading(with: story1, at: 1)
        XCTAssertEqual(view1?.titleText, story1.title)
        XCTAssertEqual(view1?.urlText, story1.url?.absoluteString)
        XCTAssertEqual(view1?.authorText, story1.author)
        XCTAssertEqual(view1?.scoreText, String(story1.score ?? 0))
    }
    
    func test_storyViewRetryButton_isVisibleOnStoryLoadError() {
        let (sut, loader) = makeSUT()
        let story = makeStory(title: "a title", author: "an author")

        sut.simulateApperance()
        loader.completeFeedLoading(with: [makeFeedId(), makeFeedId()], at: 0)
        
        let view0 = sut.simulateStoryViewVisible(at: 0)
        let view1 = sut.simulateStoryViewVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first story")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second story")

        loader.completeStoryLoading(with: story, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first story loaded successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view once first story loading completes successfully")
        
        loader.completeStoryLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second view loads with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected  retry action for second view once second view loads with error")
    }
    
    func test_storyViewRetryAction_retriesStoryLoad() {
        let (sut, loader) = makeSUT()

        sut.simulateApperance()
        loader.completeFeedLoading(with: [makeFeedId(), makeFeedId()], at: 0)
        
        let view0 = sut.simulateStoryViewVisible(at: 0)
        let view1 = sut.simulateStoryViewVisible(at: 1)
        
        XCTAssertEqual(loader.storiesRequests.count, 2, "Expected to load both story ids")
        
        loader.completeStoryLoadingWithError(at: 0)
        loader.completeStoryLoadingWithError(at: 1)
        XCTAssertEqual(loader.storiesRequests.count, 2, "Expected no more loading when story loading completes with error")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.storiesRequests.count, 3, "Expected one more loading after tapping retry action")

        view1?.simulateRetryAction()
        XCTAssertEqual(loader.storiesRequests.count, 4, "Expected another loading after tapping retry action")
    }
    
    func test_storyView_preloadStoryWhenViewNearVisible() {
        let (sut, loader) = makeSUT()

        sut.simulateApperance()
        loader.completeFeedLoading(with: [makeFeedId(), makeFeedId()], at: 0)
        XCTAssertTrue(loader.storiesRequests.isEmpty, "Expected no story request until view is near visible")
        
        sut.simulateStoryViewNearVisible(at: 0)
        XCTAssertEqual(loader.storiesRequests.count, 1, "Expected first story request once first view is visible")
        
        sut.simulateStoryViewNearVisible(at: 1)
        XCTAssertEqual(loader.storiesRequests.count, 2, "Expected second story request once second view is visible")
    }
    
    func test_storyView_cancelsStoryPreloadingWhenNotNearVisibleAnymore() {
        let (sut, loader) = makeSUT()
        let story0 = 0
        let story1 = 1

        sut.simulateApperance()
        loader.completeFeedLoading(with: [makeFeedId(id: story0), makeFeedId(id: story1)], at: 0)
        XCTAssertEqual(loader.cancelledStoriesIds, [], "Expected no cancelled stories until image is not near visible")
        
        sut.simulateStoryViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledStoriesIds, [story0], "Expected first story request once first view is visible")
        
        sut.simulateStoryViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledStoriesIds, [story0, story1], "Expected second story request once second view is visible")
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
    
    private func makeStory(id: Int = 0,
                           title: String? = nil,
                           author: String? = nil,
                           score: Int? = nil,
                           createdAt: Date = Date(),
                           totalComments: Int? = nil,
                           comments: [Int] = [],
                           type: String? = nil,
                           url: URL = URL(string: "https://any-url.com")!) -> Story {
        Story(id: id, title: title, text: title, author: author, score: score, createdAt: createdAt, totalComments: totalComments, comments: comments, type: type, url: url)
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
        
        private(set) var storiesRequests = [(id: Int, completion: (StoryLoader.Result) -> Void)]()
        
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
    
    func simulateStoryViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateStoryViewNotNearVisible(at row: Int) {
        simulateStoryViewVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
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

private extension FeedStoryCell {
    var isShowingLoadingIndicator: Bool {
        container.isShimmering
    }
    
    var isShowingRetryAction: Bool {
        !retryButton.isHidden
    }
    
    func simulateRetryAction() {
        retryButton.simulateTap()
    }
    
    var titleText: String? {
        titleLabel.text
    }
    
    var urlText: String? {
        urlLabel.text
    }
    
    var authorText: String? {
        authorLabel.text
    }
    
    var scoreText: String? {
        scoreLabel.text
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
