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
        case invalidData
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func loadStory(from url: URL, completion: @escaping (StoryLoader.Result) -> Void) -> HTTPClientTask {
        return client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(Self.map(data, from: response))
            case let .failure(error):
                completion(.failure(error))
            }
        }
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
