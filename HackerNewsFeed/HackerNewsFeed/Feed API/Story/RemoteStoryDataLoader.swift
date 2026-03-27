//
//  RemoteStoryDataLoader.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 26.03.26.
//

import Foundation

public class RemoteStoryDataLoader: StoryLoader {
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    private final class HTTPClientTaskWrapper: StoryLoaderTask {
        var wrapped: HTTPClientTask?
        private var completion: ((StoryLoader.Result) -> Void)?
        
        init(_ completion: @escaping (StoryLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: StoryLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public func loadStory(from url: URL, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                task.complete(with: Self.map(data, from: response))
            case .failure:
                task.complete(with: .failure(Error.connectivity))
            }
        }
        return task
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> StoryLoader.Result {
        do {
            let item = try StoryItemMapper.map(data, from: response)
            return .success(item)
        } catch {
            return .failure(Error.invalidData)
        }
    }
}
