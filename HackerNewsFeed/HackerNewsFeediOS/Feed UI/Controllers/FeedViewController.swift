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
    private var cellControllers = [IndexPath: FeedStoryCellController]()
    
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
        return cellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedStoryCellController {
        let cellModel = tableModel[indexPath.row]
        let cellController = FeedStoryCellController(model: cellModel, storyLoader: storyLoader!)
        cellControllers[indexPath] = cellController
        return cellController
    }
    
    private func removeCellController(forRowAt indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
}
