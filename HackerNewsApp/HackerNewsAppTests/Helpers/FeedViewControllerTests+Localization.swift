//
//  FeedViewController+Localization.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 16.03.26.
//

import Foundation
import XCTest
import HackerNewsFeed

extension FeedUIIntegrationTests {
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
    
    var loadError: String {
        LoadResourcePresenter<Any, DummyView>.loadError
    }
    
    var feedTitle: String {
        FeedPresenter.title
    }
}
