//
//  FeedStoryCellController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.03.26.
//

import UIKit
import HackerNewsFeed

public protocol FeedStoryCellControllerDelegate {
    func didRequestStory()
    func didCancelStoryRequest()
}

public final class FeedStoryCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
    public typealias ResourceViewModel = FeedStoryViewModel
    
    private let delegate: FeedStoryCellControllerDelegate
    
    private var cell: FeedStoryCell?

    public init(delegate: FeedStoryCellControllerDelegate) {
        self.delegate = delegate
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.onRetry = delegate.didRequestStory
        
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
        
        delegate.didRequestStory()
        return cell!
    }

    public func preload() {
        delegate.didRequestStory()
    }

    public func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelStoryRequest()
    }

    public func display(_ viewModel: FeedStoryViewModel) {
        cell?.authorLabel.text = viewModel.author
        cell?.titleLabel.text = viewModel.title
        cell?.scoreLabel.text = viewModel.score
        cell?.urlLabel.text = viewModel.url
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell?.container.isShimmering = viewModel.isLoading
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.retryButton.isHidden = viewModel.message == nil
    }
    
    private func releaseCellForReuse() {
        cell?.onReuse = nil
        cell = nil
    }
}
