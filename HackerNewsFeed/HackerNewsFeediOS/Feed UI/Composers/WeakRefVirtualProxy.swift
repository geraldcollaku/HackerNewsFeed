//
//  WeakRefVirtualProxy.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 21.03.26.
//

import HackerNewsFeed

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedStoryView where T: FeedStoryView {
    func display(_ viewModel: FeedStoryViewModel) {
        object?.display(viewModel)
    }
}
