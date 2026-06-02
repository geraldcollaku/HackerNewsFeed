//
//  FeedViewController+TestHelpers.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 05.04.26.
//

import UIKit
import HackerNewsFeediOS

extension ListViewController {
    func simulateApperance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            replaceRefreshControlWithFakeForiOS17Support()
        }
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func replaceRefreshControlWithFakeForiOS17Support() {
        let fake = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = fake
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
    }
    
    var errorMessage: String? {
        errorView.message
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: section)
    }
    
    func cell(row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else { return nil }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

extension ListViewController {
    @discardableResult
    func simulateStoryViewNotVisible(at row: Int) -> FeedStoryCell? {
        let view = simulateStoryViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        
        return view
    }
    
    @discardableResult
    func simulateStoryViewVisible(at index: Int) -> FeedStoryCell? {
        let view = storyView(at: index) as? FeedStoryCell
        let indexPath = IndexPath(row: index, section: feedSection)
        tableView.delegate?.tableView?(tableView, willDisplay: view!, forRowAt: indexPath)
        return view
    }
    
    @discardableResult
    func simulateStoryViewBecomingVisibleAgain(at row: Int) -> FeedStoryCell? {
        let view = simulateStoryViewNotVisible(at: row)
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedSection)
        delegate?.tableView?(tableView, willDisplay: view!, forRowAt: index)
        return view
    }
    
    func simulateStoryViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateTapOnFeedItem(at row: Int) {
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }
    
    func simulateStoryViewNotNearVisible(at row: Int) {
        simulateStoryViewVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    func storyView(at row: Int) -> UITableViewCell? {
        cell(row: row, section: feedSection)
    }
    
    func renderedStoryAuthor(at index: Int) -> String? {
        simulateStoryViewVisible(at: index)?.authorLabel.text
    }
    
    func renderedStoryTitle(at index: Int) -> String? {
        simulateStoryViewVisible(at: index)?.titleLabel.text
    }
    
    func numberOfRenderedViews() -> Int {
        numberOfRows(in: feedSection)
    }
    
    private var feedSection: Int { 0 }
}

extension ListViewController {
    func numberOfRenderedComments() -> Int {
        numberOfRows(in: commentsSection)
    }
    
    private var commentsSection: Int { 0 }
    
    private func commentView(at row: Int) -> FeedCommentCell? {
        cell(row: row, section: commentsSection) as? FeedCommentCell
    }
    
    func commentMessage(at row: Int) -> String? {
        commentView(at: row)?.messageLabel.text
    }
    
    func commentUsername(at row: Int) -> String? {
        commentView(at: row)?.usernameLabel.text
    }
    
    func commentDate(at row: Int) -> String? {
        commentView(at: row)?.dateLabel.text
    }
}

private class FakeRefreshControl: UIRefreshControl {
    private var _isRefreshing = false
    
    override var isRefreshing: Bool { _isRefreshing }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}
