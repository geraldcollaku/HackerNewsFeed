//
//  UIRefreshControl+Helpers.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 22.03.26.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
