//
//  FeedStoryCellController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.03.26.
//

import UIKit

protocol FeedStoryCellControllerDelegate {
    func didRequestStory()
    func didCancelStoryRequest()
}

final class FeedStoryCellController: FeedStoryView {
    private let delegate: FeedStoryCellControllerDelegate
    
    private var cell: FeedStoryCell?

    init(delegate: FeedStoryCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestStory()
        return cell!
    }
    
    func preload() {
        delegate.didRequestStory()
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelStoryRequest()
    }
    
    func display(_ viewModel: FeedStoryViewModel) {
        cell?.authorLabel.text = viewModel.author
        cell?.titleLabel.text = viewModel.title
        cell?.scoreLabel.text = viewModel.score
        cell?.urlLabel.text = viewModel.url
        
        cell?.container.isShimmering = viewModel.isLoading
        
        cell?.retryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestStory
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}
