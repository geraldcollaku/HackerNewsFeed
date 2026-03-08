//
//  FeedStoryCellController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.03.26.
//

import UIKit

final class FeedStoryCellController {
    private let viewModel: FeedStoryViewModel
    
    init(viewModel: FeedStoryViewModel) {
        self.viewModel = viewModel
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
