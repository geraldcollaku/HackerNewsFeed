//
//  FeedViewController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 02.03.26.
//

import HackerNewsFeed
import UIKit

public protocol StoryLoaderTask {
    func cancel()
}

public protocol StoryLoader {
    func loadStory(with id: Int) -> StoryLoaderTask
}

public final class FeedViewController: UITableViewController {
    private var feedIdLoader: FeedLoader?
    private var storyLoader: StoryLoader?
    private var tableModel = [FeedId]()
    private var tasks = [IndexPath: StoryLoaderTask]()
    
    private var onViewIsAppearing: ((FeedViewController) -> Void)?
    
    public convenience init(loader: FeedLoader, storyLoader: StoryLoader) {
        self.init()
        self.feedIdLoader = loader
        self.storyLoader = storyLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        onViewIsAppearing = { vc in
            vc.load()
            vc.onViewIsAppearing = nil
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?(self)
    }
    
    @objc public func load() {
        refreshControl?.beginRefreshing()
        feedIdLoader?.load { [weak self] result in
            if let feed = try? result.get() {
                self?.tableModel = feed
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedStoryCell()
        tasks[indexPath] = storyLoader?.loadStory(with: cellModel.id)
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellModel = tableModel[indexPath.row]
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
