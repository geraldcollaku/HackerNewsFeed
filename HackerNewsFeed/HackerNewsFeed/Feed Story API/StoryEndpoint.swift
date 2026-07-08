//
//  StoryEndpoint.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 08.07.26.
//

import Foundation

public enum StoryEndpoint {
    case get(id: FeedId)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(id):
            return baseURL.appendingPathComponent("/v0/item/\(id)")
        }
    }
}
