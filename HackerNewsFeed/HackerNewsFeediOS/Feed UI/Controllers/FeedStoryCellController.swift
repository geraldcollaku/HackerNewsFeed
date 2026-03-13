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
        cell.onRetry = presenter.loadStoryData
        return cell
    }
    
    func preload() {
        presenter.loadStoryData()
    }
    
    func cancelLoad() {
        presenter.cancelStoryLoad()
    }
    
    func display(_ story: Story) {
        cell.authorLabel.text = story.author
        cell.titleLabel.text = story.title
        cell.scoreLabel.text = String(story.score ?? 0)
        cell.urlLabel.text = story.url?.absoluteString
    }
    
    func display(isLoading: Bool) {
        cell.container.isShimmering = isLoading
    }
    
    func display(shouldRetry: Bool) {
        cell.retryButton.isHidden = !shouldRetry
    }
}
