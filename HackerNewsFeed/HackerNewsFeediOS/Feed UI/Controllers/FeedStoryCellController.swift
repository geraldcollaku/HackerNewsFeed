//
//  FeedStoryCellController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.03.26.
//

import UIKit

final class FeedStoryCellController: FeedStoryView {
    private let presenter: FeedStoryPresenter
    private lazy var cell = FeedStoryCell()
    
    init(presenter: FeedStoryPresenter) {
        self.presenter = presenter
    }
    
    func view() -> UITableViewCell {
        presenter.loadStoryData()
        return cell
    }
    
    func preload() {
        presenter.loadStoryData()
    }
    
    func cancelLoad() {
        presenter.cancelStoryLoad()
    }
    
    func display(_ viewModel: FeedStoryViewModel) {
        cell.authorLabel.text = viewModel.author
        cell.titleLabel.text = viewModel.title
        cell.scoreLabel.text = viewModel.score
        cell.urlLabel.text = viewModel.url
        
        cell.container.isShimmering = viewModel.isLoading
        
        cell.retryButton.isHidden = !viewModel.shouldRetry
        cell.onRetry = presenter.loadStoryData
    }
}
