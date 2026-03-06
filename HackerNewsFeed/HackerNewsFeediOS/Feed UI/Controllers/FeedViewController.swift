//
//  FeedViewController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 02.03.26.
//

import HackerNewsFeed
import UIKit

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    public var refreshController: FeedRefreshViewController?
    private var storyLoader: StoryLoader?
    private var tableModel = [FeedId]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var tasks = [IndexPath: StoryLoaderTask]()
    
    private var onViewDidAppear: ((FeedViewController) -> Void)?
    
    public convenience init(loader: FeedLoader, storyLoader: StoryLoader) {
        self.init()
        self.refreshController = FeedRefreshViewController(feedIdLoader: loader)
        self.storyLoader = storyLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        refreshControl = refreshController?.view
        
        refreshController?.onRefresh = { [weak self] feed in
            self?.tableModel = feed
        }
        
        onViewDidAppear = { vc in
            vc.onViewDidAppear = nil
            vc.refreshController?.refresh()
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        onViewDidAppear?(self)
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedStoryCell()
        cell.container.isShimmering = true
        cell.retryButton.isHidden = true
        
        let loadStory = { [weak self, weak cell] in
            guard let self = self else { return }
            self.tasks[indexPath] = self.storyLoader?.loadStory(with: cellModel.id) { [weak cell] result in
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
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellModel = tableModel[indexPath.row]
            tasks[indexPath] = storyLoader?.loadStory(with: cellModel.id) { _ in }
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
    
    private func cancelTask(forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
