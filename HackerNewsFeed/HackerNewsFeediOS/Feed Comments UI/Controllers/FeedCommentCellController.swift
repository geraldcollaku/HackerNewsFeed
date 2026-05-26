//
//  FeedCommentCellController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 19.05.26.
//

import UIKit
import HackerNewsFeed

public class FeedCommentCellController: NSObject {
    private let model: FeedCommentViewModel
    
    public init(model: FeedCommentViewModel) {
        self.model = model
    }
}

extension FeedCommentCellController: CellController {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FeedCommentCell = tableView.dequeueReusableCell()
        cell.usernameLabel.text = model.username
        cell.messageLabel.text = model.message
        cell.dateLabel.text = model.date
        return cell
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {}
}
