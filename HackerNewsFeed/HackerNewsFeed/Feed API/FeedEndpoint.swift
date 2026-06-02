//
//  FeedEndpoint.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 02.06.26.
//

import Foundation

public enum FeedEndpoint {
    case get
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appendingPathComponent("/v0/newstories")
                .appending(queryItems: [URLQueryItem(name: "page", value: "1")])
        }
    }
}
