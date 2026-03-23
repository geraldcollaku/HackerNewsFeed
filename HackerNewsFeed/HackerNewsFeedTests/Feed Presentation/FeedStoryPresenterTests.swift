//
//  FeedStoryPresenterTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 22.03.26.
//

import XCTest
import HackerNewsFeed

struct FeedStoryViewModel: Hashable {
    let author: String?
    let title: String?
    let score: String?
    let url: String?
    
    static var noStory: FeedStoryViewModel {
        FeedStoryViewModel(
            author: nil,
            title: nil,
            score: nil,
            url: nil)
    }
}

protocol FeedStoryView {
    func display(_ viewModel: FeedStoryViewModel)
}

struct FeedStoryLoadingViewModel {
    let isLoading: Bool
}

protocol FeedStoryLoadingView {
    func display(_ viewModel: FeedStoryLoadingViewModel)
}

final class FeedStoryPresenter {
    private let view: FeedStoryView
    private let loadingView: FeedStoryLoadingView
    
    init(view: FeedStoryView, loadingView: FeedStoryLoadingView) {
        self.view = view
        self.loadingView = loadingView
    }
    
    func didStartLoadingStory() {
        loadingView.display(FeedStoryLoadingViewModel(isLoading: true))
        view.display(.noStory)
    }
}

final class FeedStoryPresenterTests: XCTestCase {
    
    func test_init_doesNotMessageView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingStory_displaysLoadingAndNoStory() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingStory()
        
        XCTAssertEqual(view.messages, [
            .display(isLoading: true),
            .display(viewModel: .noStory)
        ])
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedStoryPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedStoryPresenter(view: view, loadingView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
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
    
    private class ViewSpy: FeedStoryView, FeedStoryLoadingView {
        enum Message: Hashable {
            case display(viewModel: FeedStoryViewModel)
            case display(isLoading: Bool)
        }
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: FeedStoryViewModel) {
            messages.insert(.display(viewModel: viewModel))
        }
        
        func display(_ viewModel: FeedStoryLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
    }
}
