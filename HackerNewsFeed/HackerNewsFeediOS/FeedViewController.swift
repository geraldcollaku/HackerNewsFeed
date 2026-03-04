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
    typealias Result = Swift.Result<Story, Error>
    
    func loadStory(with id: Int, completion: @escaping (Result) -> Void) -> StoryLoaderTask
}

public struct Story: Equatable {
    public let id: Int
    public let title: String?
    public let text: String?
    public let author: String?
    public let score: Int?
    public let createdAt: Date
    public let totalComments: Int?
    public let comments: [Int]?
    public let type: String?
    public let url: URL?

    public init(id: Int,
                title: String?,
                text: String?,
                author: String?,
                score: Int?,
                createdAt: Date,
                totalComments: Int?,
                comments: [Int]?,
                type: String?,
                url: URL?) {
        self.id = id
        self.title = title
        self.text = text
        self.author = author
        self.score = score
        self.createdAt = createdAt
        self.totalComments = totalComments
        self.comments = comments
        self.type = type
        self.url = url
    }
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
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
        tableView.prefetchDataSource = self
        
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
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellModel = tableModel[indexPath.row]
            _ = storyLoader?.loadStory(with: cellModel.id) { _ in }
        }
    }
}
