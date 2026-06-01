//
//  CommentsUIIntegrationTests.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 01.06.26.
//

import XCTest
import HackerNewsApp
import HackerNewsFeed
import HackerNewsFeediOS

class CommentsUIIntegrationTests: FeedUIIntegrationTests {
    
    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.simulateApperance()
        
        XCTAssertEqual(sut.title, commentsTitle)
    }
    
    override func test_loadFeedActions_loadsFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedIdCallCount, 0, "Expected no loading indicator before view is loaded")
        
        sut.simulateApperance()
        XCTAssertEqual(loader.loadFeedIdCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedIdCallCount, 2, "Expected another loading request once view is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedIdCallCount, 3, "Expected a third loading request once view is loaded")
    }
    
    override func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
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
    
    override func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let (sut, loader) = makeSUT()
        
        sut.simulateApperance()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [makeFeedId()], at: 0)
        assertThat(sut, isRendering: [makeFeedId()])
    }
    
    override func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let (sut, loader) = makeSUT()
        
        sut.simulateApperance()
        loader.completeFeedLoading(with: [makeFeedId()], at: 0)
        assertThat(sut, isRendering: [makeFeedId()])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    override func test_loadFeedCompletion_rendersErrorOnMessageErrorUnitilNextReload() {
        let (sut, loader) = makeSUT()
        sut.simulateApperance()
        
        loader.completeFeedLoadingWithError(at: 0)
        
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserInitiatedReload()
        
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    override func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()
        sut.simulateApperance()
        
        loader.completeFeedLoadingWithError(at: 0)
        
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    override func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.simulateApperance()
        
        let exp = expectation(description: "Waith for background queue")
        DispatchQueue.global().async {
            loader.completeFeedLoading()
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    override func test_loadStoryCompletion_dispatchesFromBackgroundToMainThread() {
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
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(loader: loader.loadPublisher)
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
}
