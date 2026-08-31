//
//  CommentsUIIntegrationTests.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 01.06.26.
//

import XCTest
import Combine
import HackerNewsApp
import HackerNewsFeed
import HackerNewsFeediOS

class CommentsUIIntegrationTests: XCTestCase {
    
    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.simulateApperance()
        
        XCTAssertEqual(sut.title, commentsTitle)
    }
    
    func test_loadCommentsActions_loadsCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCount, 0, "Expected no loading indicator before view is loaded")
        
        sut.simulateApperance()
        XCTAssertEqual(loader.loadCommentsCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCount, 1, "Expected no request until previous completes")
        
        loader.completeCommentsLoading(at: 0)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCount, 2, "Expected another loading request once view is loaded")
        
        loader.completeCommentsLoading(at: 1)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCount, 3, "Expected a third loading request once view is loaded")
    }
    
    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()
        
        sut.simulateApperance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once the user initiated a reload")
        
        loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user intiated loading is completed")
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let comment0 = makeComment(id: 0, message: "a message", username: "a username")
        let comment1 = makeComment(id: 1, message: "another message", username: "another username")

        let (sut, loader) = makeSUT()

        sut.simulateApperance()
        assertThat(sut, isRendering: [FeedComment]())

        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        assertThat(sut, isRendering: [comment0, comment1])
    }
    
    func test_loadCommentCompletion_rendersSuccessfullyLoadedEmptyCommentAfterNonEmptyFeed() {
        let comment0 = makeComment(id: 0, message: "a message", username: "a username")
        let (sut, loader) = makeSUT()
        
        sut.simulateApperance()
        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [FeedComment]())
    }

    func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.simulateApperance()
        
        let exp = expectation(description: "Waith for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func  test_loadCommentCompletion_rendersErrorOnMessageErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        sut.simulateApperance()
        
        loader.completeCommentsLoadingWithError(at: 0)
        
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserInitiatedReload()
        
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()
        sut.simulateApperance()
        
        loader.completeCommentsLoadingWithError(at: 0)
        
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_deinit_cancelsRunningRequest() {
        var cancelCallCount = 0
        var sut: ListViewController?
        
        autoreleasepool {
            sut = CommentsUIComposer.commentsComposedWith(loader: {
                PassthroughSubject<[FeedComment], Error>()
                    .handleEvents(receiveCancel: {
                        cancelCallCount += 1
                    }).eraseToAnyPublisher()
            })
        }
        
        sut?.simulateApperance()

        XCTAssertEqual(cancelCallCount, 0)

        autoreleasepool {
            sut = nil
        }

        XCTAssertEqual(cancelCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(loader: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeComment(id: Int, message: String = "any message", username: String = "any username") -> FeedComment {
        FeedComment(id: id, message: message, createdAt: Date(), username: username)
    }
    
    func assertThat(_ sut: ListViewController, isRendering comments: [FeedComment], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedComments(), comments.count, "comments count", file: file, line: line)
        
        let viewModels = FeedCommentsPresenter.map(comments).comments
        viewModels.enumerated().forEach { index, comment in
            XCTAssertEqual(sut.commentMessage(at: index), comment.message, "message at \(index)", file: file, line: line)
            XCTAssertEqual(sut.commentDate(at: index), comment.date, "date at \(index)", file: file, line: line)
            XCTAssertEqual(sut.commentUsername(at: index), comment.username, "username at \(index)", file: file, line: line)
        }
    }
    
    private class LoaderSpy {
        private var requests = [PassthroughSubject<[FeedComment], Error>]()
        
        var loadCommentsCount: Int {
            return requests.count
        }
        
        func loadPublisher() -> AnyPublisher<[FeedComment], Error> {
            let publisher = PassthroughSubject<[FeedComment], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeCommentsLoading(with comments: [FeedComment] = [], at index: Int = 0) {
            requests[index].send(comments)
            requests[index].send(completion: .finished)
        }
        
        func completeCommentsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            requests[index].send(completion: .failure(error))
        }
    }
}
