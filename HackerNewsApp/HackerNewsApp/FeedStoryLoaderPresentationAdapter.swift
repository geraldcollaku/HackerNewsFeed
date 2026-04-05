//
//  FeedStoryLoaderPresentationAdapter.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 21.03.26.
//

import HackerNewsFeed
import HackerNewsFeediOS

final class FeedStoryLoaderPresentationAdapter: FeedStoryCellControllerDelegate {
    private let model: FeedId
    private let storyLoader: StoryLoader
    private var task: StoryLoaderTask?
    
    var presenter: FeedStoryPresenter?
    
    init(model: FeedId, storyLoader: StoryLoader) {
        self.model = model
        self.storyLoader = storyLoader
    }
    
    func didRequestStory() {
        presenter?.didStartLoadingStory()
        
        task = storyLoader.loadStory(with: model.id) { [weak self] result in
            switch result {
            case let .success(story):
                self?.presenter?.didFinishLoadingStory(with: story)
            case let .failure(error):
                self?.presenter?.didFinishLoadingStory(with: error)
            }
        }
    }
    
    func didCancelStoryRequest() {
        task?.cancel()
        task = nil
    }
}
