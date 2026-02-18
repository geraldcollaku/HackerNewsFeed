//
//  FeedStory.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 18.02.26.
//

import Foundation

public struct FeedStory: Equatable {
    public let id: Int
    public let title: String?
    public let text: String?
    public let author: String
    public let score: Int?
    public let createdAt: Date
    public let totalComments: Int?
    public let comments: [Int]?
    public let type: String
    public let url: URL?
}
