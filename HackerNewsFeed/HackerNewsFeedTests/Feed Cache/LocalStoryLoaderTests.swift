//
//  LocalStoryLoaderTests.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 29.03.26.
//

import XCTest
import HackerNewsFeed

protocol StoryStore {
    typealias Result = Swift.Result<LocalStory?, Error>
    
    func retrieve(for id: Int, completion: @escaping (Result) -> Void)
}

struct LocalStory: Equatable {
    public let id: Int
    public let title: String?
    public let text: String?
    public let author: String?
    public let score: Int?
    public let createdAt: Date
    public let totalComments: Int?
    public let comments: [Int]?
    public let type: String?
    public let url: URL?

    public init(id: Int,
                title: String?,
                text: String?,
                author: String?,
                score: Int?,
                createdAt: Date,
                totalComments: Int?,
                comments: [Int]?,
                type: String?,
                url: URL?) {
        self.id = id
        self.title = title
        self.text = text
        self.author = author
        self.score = score
        self.createdAt = createdAt
        self.totalComments = totalComments
        self.comments = comments
        self.type = type
        self.url = url
    }
}

private extension LocalStory {
    func toModel() -> Story {
        Story(
            id: id,
            title: title,
            text: text,
            author: author,
            score: score,
            createdAt: createdAt,
            totalComments: totalComments,
            comments: comments,
            type: type,
            url: url)
    }
}

final class LocalStoryLoader: StoryLoader {

    private struct Task: StoryLoaderTask {
        func cancel() {}
    }
    
    enum Error: Swift.Error {
        case failed
    }
    
    private let store: StoryStore
    
    init(store: StoryStore) {
        self.store = store
    }
    
    func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
        store.retrieve(for: id) { result in
            completion(result
                .mapError { _ in Error.failed }
                .flatMap { localStory in
                    localStory.map { .success($0.toModel()) } ?? .failure(Error.failed)
                }
            )
        }
        return Task()
    }
}

class LocalStoryLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadStoryWithID_requestsStoryWithID() {
        let anyId = 0
        let (sut, store) = makeSUT()
        
        _ = sut.loadStory(with: anyId) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(forId: anyId)])
    }
    
    func test_loadStoryWithID_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failed(), when: {
            let retrievalError = anyNSError()
            store.complete(with: retrievalError)
        })
    }
    
    func test_loadStoryWithID_deliversStoryOnNonEmptyCache() {
        let (sut, store) = makeSUT()
        let uniqueStory = uniqueStory()
        
        expect(sut, toCompleteWith: .success(uniqueStory.model), when: {
            store.complete(with: uniqueStory.local)
        })
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalStoryLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalStoryLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func expect(_ sut: LocalStoryLoader,
                        toCompleteWith expectedResult: StoryLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        _ = sut.loadStory(with: anyId()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedStory), .success(expectedStory)):
                XCTAssertEqual(receivedStory, expectedStory, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failed() -> StoryLoader.Result {
        .failure(LocalStoryLoader.Error.failed)
    }
    
    private func uniqueStory() -> (model: Story, local: LocalStory) {
        let model = Story(
            id: 0,
            title: "a title",
            text: nil,
            author: "an author",
            score: 1,
            createdAt: Date(),
            totalComments: 0,
            comments: nil,
            type: "story",
            url: nil)
        let local = LocalStory(
            id: model.id,
            title: model.title,
            text: model.text,
            author: model.author,
            score: model.score,
            createdAt: model.createdAt,
            totalComments: model.totalComments,
            comments: model.comments,
            type: model.type,
            url: model.url)
        return (model, local)
    }
    
    private func anyId() -> Int {
        0
    }
    
    private class FeedStoreSpy: StoryStore {
        enum Message: Equatable {
            case retrieve(forId: Int)
        }
        
        private var completions = [(StoryStore.Result) -> Void]()
        private(set) var receivedMessages = [Message]()
        
        func retrieve(for id: Int, completion: @escaping (StoryStore.Result) -> Void) {
            receivedMessages.append(.retrieve(forId: id))
            completions.append(completion)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
        func complete(with story: LocalStory, at index: Int = 0) {
            completions[index](.success(story))
        }
    }
}
