//
//  RemoteStoryDataLoader.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 26.03.26.
//

import Foundation

public class RemoteStoryDataLoader: StoryLoader {
    private let url: (Int) -> URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: @escaping (Int) -> URL, client: HTTPClient) {
        self.url = url
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
    
    public func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url(id)) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in Error.connectivity }
                .flatMap { (data, response) in
                     Self.map(data, from: response)
                }
            )
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
