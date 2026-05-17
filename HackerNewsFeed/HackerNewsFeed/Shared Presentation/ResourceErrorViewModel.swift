//
//  FeedErrorViewModel.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 22.03.26.
//

public struct ResourceErrorViewModel {
    public let message: String?
    
    public static var noError: ResourceErrorViewModel {
        ResourceErrorViewModel(message: nil)
    }
    
    public static func error(message: String) -> ResourceErrorViewModel {
        ResourceErrorViewModel(message: message)
    }
}
