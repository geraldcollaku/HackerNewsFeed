//
//  HackerNewsFeedCacheIntegrationTests.swift
//  HackerNewsFeedCacheIntegrationTests
//
//  Created by Gerald Collaku on 12.02.26.
//

import XCTest
import HackerNewsFeed

final class HackerNewsFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    // MARK: - LocalFeedLoader Tests
    
    func test_loadFeed_deliversNoItemsOnEmptyCache() {
        let feedLoader = makeFeedLoader()
        
        expect(feedLoader, toLoad: [])
    }
    
    func test_loadFeed_deliversItemsSavedOnASeparateInstance() {
        let feedLoaderToPerformSave = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()
        let feed = uniqueIdFeed().models
        
        save(feed, with: feedLoaderToPerformSave)
        
        expect(feedLoaderToPerformLoad, toLoad: feed)
    }
    
    func test_saveFeed_overridesItemsSavedOnASeparateInstance() {
        let feedLoaderToPerformFirstSave = makeFeedLoader()
        let feedLoaderToPerformLastSave = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()
        let firstFeed = uniqueIdFeed().models
        let latestFeed = uniqueIdFeed().models
        
        save(firstFeed, with: feedLoaderToPerformFirstSave)
        save(latestFeed, with: feedLoaderToPerformLastSave)
        
        expect(feedLoaderToPerformLoad, toLoad: latestFeed)
    }
    
    // MARK: - LocalStoryLoader Tests
    
    func test_loadStory_deliversSavedDataOnASeparateInstance() {
        let storyLoaderToPerformSave = makeStoryLoader()
        let storyLoaderToPerformLoad = makeStoryLoader()
        let feedLoader = makeFeedLoader()
        let feed = uniqueIdFeed().models
        let storyId = 0
        let storyToSave = uniqueStory(id: storyId).model
        
        save(feed, with: feedLoader)
        save(storyToSave, with: storyLoaderToPerformSave)
        
        expect(storyLoaderToPerformLoad, toLoad: storyToSave, for: storyId)
    }
    
    func test_saveStory_overridesSavedStoryOnASeparateInstance() {
        let storyLoaderToPerformFirstSave = makeStoryLoader()
        let storyLoaderToPerformLastSave = makeStoryLoader()
        let storyLoaderToPerformLoad = makeStoryLoader()
        let feedLoader = makeFeedLoader()
        let feed = uniqueIdFeed().models
        let firstStory = uniqueStory(id: 0).model
        let lastStory = uniqueStory(id: 1).model

        save(feed, with: feedLoader)
        save(firstStory, with: storyLoaderToPerformFirstSave)
        save(lastStory, with: storyLoaderToPerformLastSave)
        
        expect(storyLoaderToPerformLoad, toLoad: lastStory, for: lastStory.id)
    }
    
    func test_validateFeedCache_doesNotDeleteRecentlySavedFeed() {
        let feedLoaderToPerformSave = makeFeedLoader()
        let feedLoaderToPerformValidation = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()
        let feed = uniqueIdFeed().models

        save(feed, with: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerformValidation)
        
        expect(feedLoaderToPerformLoad, toLoad: feed)
    }
    
    func test_validateCache_deletesFeedSavedOnADistantPast() {
        let feedLoaderToPerformSave = makeFeedLoader(currentDate: .distantPast)
        let feedLoaderToPerformValidation = makeFeedLoader(currentDate: Date())
        let feedLoaderToPerformLoad = makeFeedLoader(currentDate: Date())

        let feed = uniqueIdFeed().models

        save(feed, with: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerformValidation)
        
        expect(feedLoaderToPerformLoad, toLoad: [])
    }

    // MARK: - Helpers
    
    private func makeFeedLoader(currentDate: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: { currentDate })
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func makeStoryLoader(file: StaticString = #filePath, line: UInt = #line) -> LocalStoryLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalStoryLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func save(_ feed: [FeedId], with loader: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        
        loader.save(feed) { result in
            if case let .failure(error) = result {
                XCTFail("Expected to save feed successfully, got error: \(error) instead", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func validateCache(with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let validateExp = expectation(description: "Wait for validate completion")
        loader.validateCache { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to validate feed successfully, got error: \(error) instead", file: file, line: line)
            }
            validateExp.fulfill()
        }
        wait(for: [validateExp], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedId], file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(loadedFed):
                XCTAssertEqual(loadedFed, expectedFeed, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
                
            @unknown default:
                XCTFail("Received unexpected case", file: file, line: line)
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(_ story: Story, with loader: LocalStoryLoader, file: StaticString = #filePath, line: UInt = #line) {
        let receivedResult = Result { try loader.save(story) }
        if case let Result.failure(error) = receivedResult {
            XCTFail("Expected to save feed successfully, got error: \(error) instead", file: file, line: line)
        }
    }
    
    private func expect(_ sut: LocalStoryLoader, toLoad expectedStory: Story, for id: Int, file: StaticString = #filePath, line: UInt = #line) {
        let result = Result {
            try sut.loadStory(with: id)
        }
        
        switch result {
        case let .success(loadedStory):
            XCTAssertEqual(loadedStory, expectedStory, file: file, line: line)
        case let .failure(error):
            XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
        }
    }
        
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appending(path: "\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
