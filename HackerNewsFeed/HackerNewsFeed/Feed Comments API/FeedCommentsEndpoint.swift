//
//  FeedCommentsEndpoint.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 01.06.26.
//

import Foundation

public enum FeedCommentsEndpoint {
    case get(Int)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(id):
            return baseURL.appendingPathComponent("v0/story/\(id)/comments")
        }
    }
}
