//
//  FeedViewController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 02.03.26.
//

import UIKit

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    public var refreshController: FeedRefreshViewController?
    
    var tableModel = [FeedStoryCellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var onViewDidAppear: ((FeedViewController) -> Void)?
    
    public convenience init(refreshController: FeedRefreshViewController) {
        self.init()
        self.refreshController = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        refreshControl = refreshController?.view
        
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
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedStoryCellController {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}
