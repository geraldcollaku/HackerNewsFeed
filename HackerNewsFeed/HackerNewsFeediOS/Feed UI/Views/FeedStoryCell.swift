//
//  FeedStoryCell.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 03.03.26.
//

import UIKit

public final class FeedStoryCell: UITableViewCell {
    @IBOutlet private(set) public var container: UIStackView!
    @IBOutlet private(set) public var titleLabel: UILabel!
    @IBOutlet private(set) public var urlLabel: UILabel!
    @IBOutlet private(set) public var authorLabel: UILabel!
    @IBOutlet private(set) public var scoreLabel: UILabel!
    @IBOutlet private(set) public var retryButton: UIButton!
    
    var onRetry: (() -> Void)?
    
    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}
