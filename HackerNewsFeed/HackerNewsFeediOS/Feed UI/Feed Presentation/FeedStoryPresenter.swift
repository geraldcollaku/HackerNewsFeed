//
//  FeedStoryViewModel.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 08.03.26.
//

import HackerNewsFeed

protocol FeedStoryView {
    func display(isLoading: Bool)
    func display(_ story: Story)
    func display(shouldRetry: Bool)
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
        view?.display(isLoading: true)
        view?.display(shouldRetry: false)
        
        task = storyLoader.loadStory(with: model.id) { [weak self] result in
            if let story = try? result.get() {
                self?.view?.display(story)
            } else {
                self?.view?.display(shouldRetry: true)
            }
            
            self?.view?.display(isLoading: false)
        }
    }
    
    func cancelStoryLoad() {
        task?.cancel()
        task = nil
    }
}
