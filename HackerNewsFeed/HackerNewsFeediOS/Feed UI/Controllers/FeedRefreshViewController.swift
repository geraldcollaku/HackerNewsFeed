//
//  FeedRefreshViewController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.03.26.
//

import UIKit
import HackerNewsFeed

public final class FeedRefreshViewController: NSObject {
    public lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let feedIdLoader: FeedLoader
    
    public init(feedIdLoader: FeedLoader) {
        self.feedIdLoader = feedIdLoader
    }
    
    public var onRefresh: (([FeedId]) -> Void)?
    
    @objc public func refresh() {
        view.beginRefreshing()
        feedIdLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        }
    }
}
