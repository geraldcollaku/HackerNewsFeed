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

public final class FeedStoryCellController: NSObject {
    public typealias ResourceViewModel = FeedStoryViewModel

    public var onNeedsReconfigure: (() -> Void)?

    private let delegate: FeedStoryCellControllerDelegate
    private let selection: () -> Void
    private var cell: FeedStoryCell?

    public init(delegate: FeedStoryCellControllerDelegate, selection: @escaping () -> Void) {
        self.delegate = delegate
        self.selection = selection
    }
}

extension FeedStoryCellController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.onRetry = { [weak self] in
            self?.delegate.didRequestStory()
        }
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selection()
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cell = cell as? FeedStoryCell
        delegate.didRequestStory()
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoad()
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        delegate.didRequestStory()
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelLoad()
    }

    private func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelStoryRequest()
    }

    private func releaseCellForReuse() {
        cell?.onReuse = nil
        cell = nil
    }
}

extension FeedStoryCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
    public func display(_ viewModel: FeedStoryViewModel) {
        cell?.authorLabel.text = viewModel.author
        cell?.titleLabel.text = viewModel.title
        cell?.scoreLabel.text = viewModel.score
        cell?.urlLabel.text = viewModel.url
        onNeedsReconfigure?()
    }

    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell?.container.isShimmering = viewModel.isLoading
    }

    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.retryButton.isHidden = viewModel.message == nil
    }
}
