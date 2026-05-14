//
//  FeedCommentsMapper.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 13.05.26.
//

import Foundation

public enum FeedCommentsMapper {
    private struct Item: Decodable {
        let id: Int
        let message: String
        let created_at: Date
        let author: Author

        struct Author: Decodable {
            let username: String
        }

        var comment: FeedComment {
            FeedComment(id: id, message: message, createdAt: created_at, username: author.username)
        }
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedComment] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard isOK(response), let items = try? decoder.decode([Item].self, from: data) else {
            throw RemoteCommentsLoader.Error.invalidData
        }

        return items.map { $0.comment }
    }

    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}
