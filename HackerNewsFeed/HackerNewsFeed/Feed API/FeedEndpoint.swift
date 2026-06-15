//
//  FeedEndpoint.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 02.06.26.
//

import Foundation

public enum FeedEndpoint {
    case get(after: FeedId? = nil)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(feed):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/v0/newstories"
            components.queryItems = [
                URLQueryItem(name: "limit", value: "10"),
                feed.map { URLQueryItem(name: "after_id", value: "\($0.id)") }
            ].compactMap { $0 }
            return components.url!
        }
    }
}
