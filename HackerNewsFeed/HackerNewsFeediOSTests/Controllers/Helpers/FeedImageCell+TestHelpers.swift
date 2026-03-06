//
//  FeedImageCell+TestHelpers.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 06.03.26.
//

import UIKit
import HackerNewsFeediOS

extension FeedStoryCell {
    var isShowingLoadingIndicator: Bool {
        container.isShimmering
    }
    
    var isShowingRetryAction: Bool {
        !retryButton.isHidden
    }
    
    func simulateRetryAction() {
        retryButton.simulateTap()
    }
    
    var titleText: String? {
        titleLabel.text
    }
    
    var urlText: String? {
        urlLabel.text
    }
    
    var authorText: String? {
        authorLabel.text
    }
    
    var scoreText: String? {
        scoreLabel.text
    }

}
