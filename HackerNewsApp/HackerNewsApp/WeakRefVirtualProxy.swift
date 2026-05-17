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

extension WeakRefVirtualProxy: ResourceErrorView where T: ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ResourceView where T: ResourceView, T.ResourceViewModel == FeedStoryViewModel {
    func display(_ viewModel: FeedStoryViewModel) {
        object?.display(viewModel)
    }
}
