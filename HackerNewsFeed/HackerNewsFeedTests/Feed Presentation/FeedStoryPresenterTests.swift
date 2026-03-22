//
//  FeedStoryPresenterTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 22.03.26.
//

import XCTest

final class FeedStoryPresenter {
    init(view: Any) {
        
    }
}

final class FeedStoryPresenterTests: XCTestCase {
    
    func test_init_doesNotMessageView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedStoryPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedStoryPresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy {
        let messages = [Any]()
    }
}
