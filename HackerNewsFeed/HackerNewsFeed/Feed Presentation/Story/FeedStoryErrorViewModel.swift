//
//  FeedStoryErrorViewModel.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 23.03.26.
//

public struct FeedStoryErrorViewModel {
    public let errorMessage: String?
    
    public static var none = FeedStoryErrorViewModel(errorMessage: nil)
    
    public static func error(message: String?) -> FeedStoryErrorViewModel {
        FeedStoryErrorViewModel(errorMessage: message)
    }
}
