//
//  FeedCommentCellController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 19.05.26.
//

import UIKit
import HackerNewsFeed

public class FeedCommentCellController: CellController {
    private let model: FeedCommentViewModel
    
    public init(model: FeedCommentViewModel) {
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: FeedCommentCell = tableView.dequeueReusableCell()
        cell.usernameLabel.text = model.username
        cell.messageLabel.text = model.message
        cell.dateLabel.text = model.date
        return cell
    }
}
