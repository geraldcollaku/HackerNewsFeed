//
//  FeedUIIntegrationTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 27.02.26.
//

import XCTest
import HackerNewsApp
import HackerNewsFeed
import HackerNewsFeediOS

class FeedUIIntegrationTests: XCTestCase {
    
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()

        sut.simulateApperance()
        
        XCTAssertEqual(sut.title, feedTitle)
    }
    
    func test_imageSelection_notifiesHandler() {
        let item0 = makeFeedId(id: 0)
        let item1 =  makeFeedId(id: 1)
        var selectedItems = [FeedId]()
        let (sut, loader) = makeSUT(selection: { selectedItems.append($0) })
        
        sut.simulateApperance()
        loader.completeFeedLoading(with: [item0, item1], at: 0)
        
        sut.simulateTapOnFeedItem(at: 0)
        XCTAssertEqual(selectedItems, [item0])
        
        sut.simulateTapOnFeedItem(at: 1)
        XCTAssertEqual(selectedItems, [item0, item1])
    }
    
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
    
    func test_loadMoreActions_requestMoreFromLoader() {
        let (sut, loader) = makeSUT()
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading()
        
        XCTAssertEqual(loader.loadMoreCallCount, 0, "Expected no requests until load more action")
        
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected load more request")
        
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 1, "Expected load more request")
        
        loader.completeLoadMore(lastPage: false, at: 0)
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 2, "Expected request after load more completed with more pages")
        
        loader.completeLoadMoreWithError(at: 1)
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 3, "Expected request after load more failure")
        
        loader.completeLoadMore(lastPage: true, at: 0)
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 3, "Expected no request after loading all pages")
    }
    
    func test_loadingMoreIndicator_isVisibleWhileLoadingMore() {
        let (sut, loader) = makeSUT()

        sut.simulateApperance()
        XCTAssertFalse(sut.isShowingLoadMoreIndicator, "Expected no loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadMoreIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateLoadMoreFeedAction()
        XCTAssertTrue(sut.isShowingLoadMoreIndicator, "Expected  loading indicator on load more action")

        loader.completeLoadMore(at: 0)
        XCTAssertFalse(sut.isShowingLoadMoreIndicator, "Expected no loading indicator once user initiated reload completes successfully")
        
        sut.simulateLoadMoreFeedAction()
        XCTAssertTrue(sut.isShowingLoadMoreIndicator, "Expected  loading indicator on a second load more action")
        
        loader.completeLoadMoreWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadMoreIndicator, "Expected no loading indicator once user initiated reload completes with error")
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
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [makeFeedId()], at: 0)
        assertThat(sut, isRendering: [makeFeedId()])
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let feed0 = makeFeedId()
        let feed1 = makeFeedId()
        let feed2 = makeFeedId()
        let (sut, loader) = makeSUT()
        
        sut.simulateApperance()
        loader.completeFeedLoading(with: [feed0], at: 0)
        assertThat(sut, isRendering: [feed0])
        
        sut.simulateLoadMoreFeedAction()
        loader.completeLoadMore(with: [feed1, feed2])
        assertThat(sut, isRendering: [feed1, feed2])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let feed0 = makeFeedId()
        let (sut, loader) = makeSUT()

        sut.simulateApperance()
        loader.completeFeedLoading(with: [feed0], at: 0)
        assertThat(sut, isRendering: [feed0])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [feed0])
        
        sut.simulateLoadMoreFeedAction()
        loader.completeLoadMoreWithError(at: 0)
        assertThat(sut, isRendering: [feed0])
    }
    
    func test_loadFeedCompletion_rendersErrorOnMessageErrorUnitilNextReload() {
        let (sut, loader) = makeSUT()
        sut.simulateApperance()
        
        loader.completeFeedLoadingWithError(at: 0)
        
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserInitiatedReload()
        
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()
        sut.simulateApperance()
        
        loader.completeFeedLoadingWithError(at: 0)
        
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        
        XCTAssertEqual(sut.errorMessage, nil)
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
    
    func test_storyView_doesNotRenderLoadedStoryWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        let story0 = makeStory(id: 0,
                               title: "a title",
                               author: "an author",
                               score: 0,
                               url: URL(string: "https://a-url.com")!)

        sut.simulateApperance()
        loader.completeFeedLoading(with: [makeFeedId(id: story0.id)], at: 0)
        
        let view = sut.simulateStoryViewNotVisible(at: 0)
        loader.completeStoryLoading(with: story0)
        
        XCTAssertNil(view?.authorText, "Expected no author when a story load finishes after story view is not visible anymore")
        XCTAssertNil(view?.scoreText, "Expected no score when a story load finishes after story view is not visible anymore")
        XCTAssertNil(view?.titleText, "Expected no title when a story load finishes after story view is not visible anymore")
        XCTAssertNil(view?.urlText, "Expected no url when a story load finishes after story view is not visible anymore")
    }
    
    func test_storyView_reloadsDataWhenBecomingVisibleAgain() {
        let (sut, loader) = makeSUT()
        let story0 = 0
        let story1 = 1
        
        sut.simulateApperance()
        loader.completeFeedLoading(with: [makeFeedId(id: story0), makeFeedId(id: story1)], at: 0)
        sut.simulateStoryViewBecomingVisibleAgain(at: 0)
        
        XCTAssertEqual(loader.storiesRequests.count, 2, "Expected to load the story again when a story view becomes visible again")

        sut.simulateStoryViewBecomingVisibleAgain(at: 1)
        XCTAssertEqual(loader.storiesRequests.count, 4, "Expected to load the two stories again when the second story view becomes visible again")
    }
    
    func test_storyView_doesNotShowDataFromPreviousRequestWhenCellIsReused() throws {
        let (sut, loader) = makeSUT()
        let story0 = makeStory(id: 0,
                               title: "a title",
                               author: "an author",
                               score: 0,
                               url: URL(string: "https://a-url.com")!)
        
        sut.simulateApperance()
        loader.completeFeedLoading(with: [makeFeedId(id: story0.id)], at: 0)

        let view0 = try XCTUnwrap(sut.simulateStoryViewVisible(at: 0))
        view0.prepareForReuse()
        
        loader.completeStoryLoading(with: story0)
        
        XCTAssertNil(view0.authorText, "Expected no author for reused view once story loading completes successfully")
        XCTAssertNil(view0.scoreText, "Expected no score for reused view once story loading completes successfully")
        XCTAssertNil(view0.titleText, "Expected no title for reused view once story loading completes successfully")
        XCTAssertNil(view0.urlText, "Expected no url for reused view once story loading completes successfully")
    }
    
    func test_storyView_showsDataForNewViewRequestsAfterPreviousViewIsReused() throws {
        let (sut, loader) = makeSUT()
        let story0 = makeStory(id: 0,
                               title: "a title",
                               author: "an author",
                               score: 0,
                               url: URL(string: "https://a-url.com")!)
        let story1 = makeStory(id: 1,
                               title: "another title",
                               author: "another author",
                               score: 1,
                               url: URL(string: "https://another-url.com")!)
        
        sut.simulateApperance()
        loader.completeFeedLoading(with: [makeFeedId(id: story0.id), makeFeedId(id: story1.id)], at: 0)
        
        let previousView = try XCTUnwrap(sut.simulateStoryViewVisible(at: 0))
        
        let newView = try XCTUnwrap(sut.simulateStoryViewVisible(at: 1))
        
        previousView.prepareForReuse()
        
        loader.completeStoryLoading(with: story1, at: 1)
        
        XCTAssertEqual(newView.authorText, story1.author)
        XCTAssertEqual(newView.titleText, story1.title)
        XCTAssertEqual(newView.urlText, story1.url?.absoluteString)
    }
    
    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()

        sut.simulateApperance()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeFeedLoading()
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadMoreCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()

        sut.simulateApperance()
        loader.completeFeedLoading()
        sut.simulateLoadMoreFeedAction()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeLoadMore()
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadStoryCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        let feed = makeFeedId()
        
        sut.simulateApperance()
        loader.completeFeedLoading(with: [feed])
        sut.simulateStoryViewVisible(at: 0)
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeStoryLoading(with: self.makeStory(id: feed.id))
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(selection: @escaping (FeedId) -> Void = { _ in },
                         file: StaticString = #file,
                         line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(
            loader: loader.loadPublisher,
            storyLoader: loader.loadStoryPublisher,
            selection: selection
        )
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeFeedId(id: Int = Int.random(in: 0 ... 100000)) -> FeedId {
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

