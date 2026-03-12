//
//  FeedRefreshViewController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.03.26.
//

import UIKit

public final class FeedRefreshViewController: NSObject, FeedLoadingView {
    public lazy var view = loadView()
    
    private let presenter: FeedPresenter
    
    public init(presenter: FeedPresenter) {
        self.presenter = presenter
    }
        
    @objc public func refresh() {
        presenter.loadFeed()
    }
    
    public func display(isLoading: Bool) {
        if isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
