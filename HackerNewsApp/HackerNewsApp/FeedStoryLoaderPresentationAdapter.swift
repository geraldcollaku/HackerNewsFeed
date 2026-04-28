//
//  FeedStoryLoaderPresentationAdapter.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 21.03.26.
//

import Combine
import HackerNewsFeed
import HackerNewsFeediOS

final class FeedStoryLoaderPresentationAdapter: FeedStoryCellControllerDelegate {
    private let model: FeedId
    private let storyLoader: (Int) -> StoryLoader.Publisher
    private var cancellable: Cancellable?
    
    var presenter: FeedStoryPresenter?
    
    init(model: FeedId, storyLoader: @escaping (Int) -> StoryLoader.Publisher) {
        self.model = model
        self.storyLoader = storyLoader
    }
    
    func didRequestStory() {
        presenter?.didStartLoadingStory()
        
        cancellable = storyLoader(model.id)
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                    case let .failure(error):
                        self?.presenter?.didFinishLoadingStory(with: error)
                    }
                },
                receiveValue: { [weak self] story in
                    self?.presenter?.didFinishLoadingStory(with: story)
                })
    }
    
    func didCancelStoryRequest() {
        cancellable?.cancel()
    }
}
