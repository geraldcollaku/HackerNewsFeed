//
//  RemoteFeedLoader.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 24.12.25.
//

import Foundation

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error {
        case connectivity
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { error in
            completion(.connectivity)
        }
    }
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}
