//
//  FeedStoryCellController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.03.26.
//

import UIKit
import HackerNewsFeed

final class FeedStoryCellController {
    private var task: StoryLoaderTask?
    private let model: FeedId
    private let storyLoader: StoryLoader
    
    init(model: FeedId, storyLoader: StoryLoader) {
        self.model = model
        self.storyLoader = storyLoader
    }
    
    func view() -> UITableViewCell {
        let cell = FeedStoryCell()
        cell.container.isShimmering = true
        cell.retryButton.isHidden = true
        
        let loadStory = { [weak self, weak cell] in
            guard let self = self else { return }
            self.task = storyLoader.loadStory(with: model.id) { [weak cell] result in
                if let story = try? result.get() {
                    cell?.authorLabel.text = story.author
                    cell?.titleLabel.text = story.title
                    cell?.scoreLabel.text = String(story.score ?? 0)
                    cell?.urlLabel.text = story.url?.absoluteString
                    cell?.retryButton.isHidden = true
                } else {
                    cell?.retryButton.isHidden = false
                }
                cell?.container.isShimmering = false
            }
        }
        
        cell.onRetry = loadStory
        loadStory()
        
        return cell
    }
    
    func preload() {
        task = storyLoader.loadStory(with: model.id) { _ in }
    }
    
    deinit {
        task?.cancel()
    }
}
