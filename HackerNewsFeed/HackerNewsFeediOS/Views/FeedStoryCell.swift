//
//  FeedStoryCell.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 03.03.26.
//

import UIKit

public final class FeedStoryCell: UITableViewCell {
    public let container = UIView()
    public let titleLabel = UILabel()
    public let urlLabel = UILabel()
    public let authorLabel = UILabel()
    public let scoreLabel = UILabel()
    
    private(set) public lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
