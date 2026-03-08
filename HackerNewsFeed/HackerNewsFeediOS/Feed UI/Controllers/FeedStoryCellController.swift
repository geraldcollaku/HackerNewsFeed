//
//  FeedStoryCellController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.03.26.
//

import UIKit
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

final class FeedStoryCellController {
    private let viewModel: FeedStoryViewModel
    
    init(model: FeedId, storyLoader: StoryLoader) {
        self.viewModel = FeedStoryViewModel(model: model, storyLoader: storyLoader)
    }
    
    func view() -> UITableViewCell {
        let cell = binded(FeedStoryCell())
        viewModel.loadStoryData()
        return cell
    }
    
    func preload() {
        viewModel.loadStoryData()
    }
    
    func cancelLoad() {
        viewModel.cancelStoryLoad()
    }
    
    private func binded(_ cell: FeedStoryCell) -> FeedStoryCell {
        viewModel.onStoryLoad = { [weak cell] story in
            cell?.authorLabel.text = story.author
            cell?.titleLabel.text = story.title
            cell?.scoreLabel.text = String(story.score ?? 0)
            cell?.urlLabel.text = story.url?.absoluteString
        }
        cell.onRetry = viewModel.loadStoryData
        
        viewModel.onStoryLoadingStateChange = { [weak cell] isLoading in
            cell?.container.isShimmering = isLoading
        }
        
        viewModel.onShouldRetryLoadStateChange = { [weak cell] shouldRetry in
            cell?.retryButton.isHidden = !shouldRetry
        }
        return cell
    }
}
