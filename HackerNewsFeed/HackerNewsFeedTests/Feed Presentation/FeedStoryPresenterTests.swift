//
//  FeedStoryPresenterTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 22.03.26.
//

import XCTest
import HackerNewsFeed

struct FeedStoryViewModel {
    let author: String?
    let title: String?
    let score: String?
    let url: String?
    
    let isLoading: Bool
    let shouldRetry: Bool
}

protocol FeedStoryView {
    func display(_ viewModel: FeedStoryViewModel)
}

final class FeedStoryPresenter {
    private let view: FeedStoryView
    
    init(view: FeedStoryView) {
        self.view = view
    }
    
    func didStartLoadingStory() {
        view.display(FeedStoryViewModel(
            author: nil,
            title: nil,
            score: nil,
            url: nil,
            isLoading: true,
            shouldRetry: false))
    }
}

final class FeedStoryPresenterTests: XCTestCase {
    
    func test_init_doesNotMessageView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingStory_displaysLoadingStory() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingStory()
        
        let message = view.messages.first
        
        XCTAssertNil(message?.author)
        XCTAssertNil(message?.title)
        XCTAssertNil(message?.score)
        XCTAssertNil(message?.url)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedStoryPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedStoryPresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: FeedStoryView {
        private(set) var messages = [FeedStoryViewModel]()
        
        func display(_ viewModel: FeedStoryViewModel) {
            messages.append(viewModel)
        }
    }
}
