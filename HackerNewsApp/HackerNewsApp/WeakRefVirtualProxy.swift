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

extension WeakRefVirtualProxy: ResourceLoadingView where T: ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel) {
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

extension WeakRefVirtualProxy: FeedStoryLoadingView where T: FeedStoryLoadingView {
    func display(_ viewModel: FeedStoryLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedStoryErrorView where T: FeedStoryErrorView {
    func display(_ viewModel: FeedStoryErrorViewModel) {
        object?.display(viewModel)
    }
}

