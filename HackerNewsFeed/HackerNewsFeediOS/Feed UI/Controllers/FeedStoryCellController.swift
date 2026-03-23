//
//  FeedStoryCellController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.03.26.
//

import UIKit
import HackerNewsFeed

protocol FeedStoryCellControllerDelegate {
    func didRequestStory()
    func didCancelStoryRequest()
}

final class FeedStoryCellController: FeedStoryView, FeedStoryLoadingView, FeedStoryErrorView {
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
    
    func display(_ viewModel: FeedStoryLoadingViewModel) {
        cell?.container.isShimmering = viewModel.isLoading
    }
    
    func display(_ viewModel: FeedStoryViewModel) {
        cell?.authorLabel.text = viewModel.author
        cell?.titleLabel.text = viewModel.title
        cell?.scoreLabel.text = viewModel.score
        cell?.urlLabel.text = viewModel.url
        
        cell?.onRetry = delegate.didRequestStory
        
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
    }
    
    func display(_ viewModel: FeedStoryErrorViewModel) {
        cell?.retryButton.isHidden = viewModel.errorMessage == nil
    }
    
    private func releaseCellForReuse() {
        cell?.onReuse = nil
        cell = nil
    }
}
