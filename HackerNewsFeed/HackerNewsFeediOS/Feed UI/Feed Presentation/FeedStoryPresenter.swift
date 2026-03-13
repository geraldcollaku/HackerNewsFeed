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
    private var task: StoryLoaderTask?
    private let model: FeedId
    private let storyLoader: StoryLoader
    
    var view: FeedStoryView?
    
    init(model: FeedId, storyLoader: StoryLoader) {
        self.model = model
        self.storyLoader = storyLoader
    }
    
    func loadStoryData() {
        view?.display(FeedStoryViewModel(
            author: nil,
            title: nil,
            score: nil,
            url: nil,
            isLoading: true,
            shouldRetry: false))
   
        task = storyLoader.loadStory(with: model.id) { [weak self] result in
            if let story = try? result.get() {
                
                self?.view?.display(FeedStoryViewModel(
                    author: story.author,
                    title: story.title,
                    score: String(story.score ?? 0),
                    url: story.url?.absoluteString,
                    isLoading: false,
                    shouldRetry: false))
                
            } else {
                self?.view?.display(FeedStoryViewModel(
                    author: nil,
                    title: nil,
                    score: nil,
                    url: nil,
                    isLoading: false,
                    shouldRetry: true))
            }
        }
    }
    
    func cancelStoryLoad() {
        task?.cancel()
        task = nil
    }
}
