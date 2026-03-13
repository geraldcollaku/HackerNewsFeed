//
//  FeedStoryCellController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.03.26.
//

import UIKit

final class FeedStoryCellController: FeedStoryView {
    private lazy var cell = FeedStoryCell()
    
    let didRequestStory: () -> Void
    let didCancelStoryRequest: () -> Void
    
    init(didRequestStory: @escaping () -> Void, didCancelStoryRequest: @escaping () -> Void) {
        self.didRequestStory = didRequestStory
        self.didCancelStoryRequest = didCancelStoryRequest
    }
    
    func view() -> UITableViewCell {
        didRequestStory()
        return cell
    }
    
    func preload() {
        didRequestStory()
    }
    
    func cancelLoad() {
        didCancelStoryRequest()
    }
    
    func display(_ viewModel: FeedStoryViewModel) {
        cell.authorLabel.text = viewModel.author
        cell.titleLabel.text = viewModel.title
        cell.scoreLabel.text = viewModel.score
        cell.urlLabel.text = viewModel.url
        
        cell.container.isShimmering = viewModel.isLoading
        
        cell.retryButton.isHidden = !viewModel.shouldRetry
        cell.onRetry = didRequestStory
    }
}
