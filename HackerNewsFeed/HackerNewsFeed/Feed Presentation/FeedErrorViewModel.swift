//
//  FeedErrorViewModel.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 22.03.26.
//

public struct FeedErrorViewModel {
    public let message: String?
    
    public static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: nil)
    }
    
    public static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
