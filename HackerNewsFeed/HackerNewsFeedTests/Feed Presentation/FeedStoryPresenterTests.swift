//
//  FeedStoryPresenterTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 22.03.26.
//

import XCTest
import HackerNewsFeed

final class FeedStoryPresenterTests: XCTestCase {
    
    func test_map_createsViewModel() {
        let story = Story(
            id: 1,
            title: "a title",
            text: nil,
            author: "an author",
            score: 42,
            createdAt: Date(),
            totalComments: 0,
            comments: nil,
            type: "story",
            url: URL(string: "https://any-url.com")!)

        let viewModel = FeedStoryPresenter.map(story)

        XCTAssertEqual(viewModel.author, "an author")
        XCTAssertEqual(viewModel.title, "a title")
        XCTAssertEqual(viewModel.score, "42")
        XCTAssertEqual(viewModel.url, "https://any-url.com")
    }
    
    func test_init_doesNotMessageView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingStory_displaysLoadingAndNoStory() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingStory()
        
        XCTAssertEqual(view.messages, [
            .display(isLoading: true),
            .display(viewModel: .noStory),
            .display(errorMessage: .none)
        ])
    }
    
    func test_didFinishLoadingStory_displaysStoryAndStopsLoading() {
        let (sut, view) = makeSUT()
        let validStory = makeValidStory()
        
        sut.didFinishLoadingStory(with: validStory.model)
        
        XCTAssertEqual(view.messages, [
            .display(isLoading: false),
            .display(errorMessage: .none),
            .display(viewModel: validStory.viewModel)
        ])
    }
    
    func test_didFinishLoadingStoryWithError_displaysNoStoryAndDisplayRetry() {
        let (sut, view) = makeSUT()
        let error = anyNSError()
        
        sut.didFinishLoadingStory(with: error)
        
        XCTAssertEqual(view.messages, [
            .display(isLoading: false),
            .display(errorMessage: localized("FEED_STORY_VIEW_CONNECTION_ERROR"))
        ])
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedStoryPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedStoryPresenter(storyView: view, loadingView: view, errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Story"
        let bundle = Bundle(for: FeedStoryPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        
        return value
    }
    
    private func makeValidStory(id: Int = 0,
                                title: String? = "a title",
                                author: String? = "an author",
                                score: Int? = 0,
                                createdAt: Date = Date(),
                                totalComments: Int? = 0,
                                comments: [Int] = [],
                                type: String? = "a type",
                                url: URL = URL(string: "https://any-url.com")!) -> (model: Story, viewModel: FeedStoryViewModel) {
       let model = Story(id: id, title: title, text: title, author: author, score: score, createdAt: createdAt, totalComments: totalComments, comments: comments, type: type, url: url)
        let viewModel = FeedStoryViewModel(
            author: model.author,
            title: model.title,
            score: String(model.score!),
            url: model.url?.absoluteString)
        return (model, viewModel)
    }
    
    private class ViewSpy: FeedStoryView, FeedStoryLoadingView, FeedStoryErrorView {
        enum Message: Hashable {
            case display(viewModel: FeedStoryViewModel)
            case display(isLoading: Bool)
            case display(errorMessage: String?)
        }
        
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: FeedStoryViewModel) {
            messages.insert(.display(viewModel: viewModel))
        }
        
        func display(_ viewModel: FeedStoryLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedStoryErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.errorMessage))
        }
    }
}
