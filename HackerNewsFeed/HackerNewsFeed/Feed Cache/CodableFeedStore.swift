//
//  CodableFeedStore.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 26.01.26.
//

import Foundation

public class CodableFeedStore: FeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedId]
        let timestamp: Date
        
        var localFeed: [LocalFeedId] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableFeedId: Codable {
        private let id: Int
        
        init(_ id: LocalFeedId) {
            self.id = id.id
        }
        
        var local: LocalFeedId {
            LocalFeedId(id: id)
        }
    }
    
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        guard let data = try? Data.init(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func insert(_ feed: [LocalFeedId], timestamp: Date, completion: @escaping InsertionCompletion) {
        do {
            let encoder = JSONEncoder()
            let cache = Cache(feed: feed.map(CodableFeedId.init), timestamp: timestamp)
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            return completion(nil)
        }
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
           completion(error)
        }
    }
}
