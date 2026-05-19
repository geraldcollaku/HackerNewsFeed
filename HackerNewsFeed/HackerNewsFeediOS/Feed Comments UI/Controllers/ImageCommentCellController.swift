//
//  ImageCommentCellController.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 19.05.26.
//

import UIKit
import HackerNewsFeed

public class ImageCommentCellController: CellController {
    private let model: FeedCommentViewModel
    
    public init(model: FeedCommentViewModel) {
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        UITableViewCell()
    }
    
    public func preload() {
        
    }
    
    public func cancelLoad() {
        
    }
}
