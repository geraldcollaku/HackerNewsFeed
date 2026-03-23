//
//  FeedStoryViewModel.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 23.03.26.
//

public struct FeedStoryViewModel: Hashable {
    public let author: String?
    public let title: String?
    public let score: String?
    public let url: String?
    
    public static var noStory: FeedStoryViewModel {
        FeedStoryViewModel(
            author: nil,
            title: nil,
            score: nil,
            url: nil)
    }
    
    public init(author: String?,
                title: String?,
                score: String?,
                url: String?) {
        self.author = author
        self.title = title
        self.score = score
        self.url = url
    }
}
