//
//  XCTestCache+StoryLoader.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 03.04.26.
//

import XCTest
import HackerNewsFeed

protocol StoryLoaderTestCase: XCTestCase {}

extension StoryLoaderTestCase {
    func expect(_ sut: StoryLoader, for id: Int, toCompleteWith expectedResult: StoryLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.loadStory(with: id) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedStory), .success(expectedStory)):
                XCTAssertEqual(receivedStory, expectedStory, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError)
            default:
                XCTFail("Expected \(expectedResult), got result \(receivedResult) instead")
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}
