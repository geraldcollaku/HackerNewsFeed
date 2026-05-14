//
//  FeedComment.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 13.05.26.
//

import Foundation

public struct FeedComment: Equatable {
    public let id: Int
    public let message: String
    public let createdAt: Date
    public let username: String
    
    public init(id: Int, message: String, createdAt: Date, username: String) {
        self.id = id
        self.message = message
        self.createdAt = createdAt
        self.username = username
    }
}
