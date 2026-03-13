//
//  FeedStoryViewModel.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 08.03.26.
//

import HackerNewsFeed

import Foundation

protocol FeedStoryView {
    func display(_ viewModel: FeedStoryViewModel)
}

final class FeedStoryPresenter {
    var view: FeedStoryView?
    
    func didStartLoadingStory() {
        view?.display(FeedStoryViewModel(
            author: nil,
            title: nil,
            score: nil,
            url: nil,
            isLoading: true,
            shouldRetry: false))
    }
    
    func didFinishLoadingStory(with model: Story) {
        view?.display(FeedStoryViewModel(
            author: model.author,
            title: model.title,
            score: String(model.score ?? 0),
            url: model.url?.absoluteString,
            isLoading: false,
            shouldRetry: false))
    }
    
    func didFinishLoadingStory(with error: Error) {
        view?.display(FeedStoryViewModel(
            author: nil,
            title: nil,
            score: nil,
            url: nil,
            isLoading: false,
            shouldRetry: true))
    }
}
