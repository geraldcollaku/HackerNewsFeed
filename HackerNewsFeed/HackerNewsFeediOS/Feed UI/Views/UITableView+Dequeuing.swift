//
//  UITableView+Dequeuing.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 15.03.26.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
