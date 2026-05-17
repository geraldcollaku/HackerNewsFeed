//
//  FeedCommentsPresenter.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 17.05.26.
//

import Foundation

public struct FeedCommentsViewModel {
    public let comments: [FeedCommentViewModel]
}

public struct FeedCommentViewModel: Equatable {
    public let message: String
    public let date: String
    public let username: String
    
    public init(message: String, date: String, username: String) {
        self.message = message
        self.date = date
        self.username = username
    }
}

public final class FeedCommentsPresenter {
    public static var title: String {
        NSLocalizedString("FEED_COMMENTS_VIEW_TITLE",
                          tableName: "FeedComments",
                          bundle: Bundle(for: Self.self),
                          comment: "Title for feed comments view")
    }
    
    public static func map(
        _ comments: [FeedComment],
        currentDate: Date = Date(),
        calendar: Calendar = .current,
        locale: Locale = .current
    ) -> FeedCommentsViewModel {
        let formatter = RelativeDateTimeFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        
        return FeedCommentsViewModel(comments: comments.map { comment in
            FeedCommentViewModel(message: comment.message,
                                 date: formatter.localizedString(for: comment.createdAt, relativeTo: currentDate),
                                 username: comment.username)
        })
    }
}
