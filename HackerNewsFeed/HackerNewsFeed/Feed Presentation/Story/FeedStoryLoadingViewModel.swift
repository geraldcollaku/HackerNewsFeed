//
//  FeedStoryLoadingViewModel.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 23.03.26.
//

public struct FeedStoryLoadingViewModel {
    public let isLoading: Bool
    
    public static var loading = FeedStoryLoadingViewModel(isLoading: true)
    public static var stopped = FeedStoryLoadingViewModel(isLoading: false)
}
