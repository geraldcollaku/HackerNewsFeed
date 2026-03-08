//
//  FeedStoryViewModel.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 08.03.26.
//


import HackerNewsFeed

final class FeedStoryViewModel {
    typealias Observer<T> = (T) -> Void
    
    private var task: StoryLoaderTask?
    private let model: FeedId
    private let storyLoader: StoryLoader
    
    var onStoryLoadingStateChange: Observer<Bool>?
    var onStoryLoad: Observer<Story>?
    var onShouldRetryLoadStateChange: Observer<Bool>?
    
    init(model: FeedId, storyLoader: StoryLoader) {
        self.model = model
        self.storyLoader = storyLoader
    }
    
    func loadStoryData() {
        onStoryLoadingStateChange?(true)
        onShouldRetryLoadStateChange?(false)
        
        task = storyLoader.loadStory(with: model.id) { [weak self] result in
            if let story = try? result.get() {
                self?.onStoryLoad?(story)
                self?.onShouldRetryLoadStateChange?(false)
            } else {
                self?.onShouldRetryLoadStateChange?(true)
            }
            
            self?.onStoryLoadingStateChange?(false)
        }
    }
    
    func cancelStoryLoad() {
        task?.cancel()
        task = nil
    }
}