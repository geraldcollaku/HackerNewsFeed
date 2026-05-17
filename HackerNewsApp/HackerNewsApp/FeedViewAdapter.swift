//
//  FeedViewAdapter.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 21.03.26.
//

import HackerNewsFeed
import HackerNewsFeediOS

class FeedViewAdapter: ResourceView {
    private weak var controller: FeedViewController?
    private let loader: (Int) -> StoryLoader.Publisher
    
    init(controller: FeedViewController, loader: @escaping (Int) -> StoryLoader.Publisher) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = FeedStoryLoaderPresentationAdapter(
                model: model,
                storyLoader: loader)
            let view = FeedStoryCellController(delegate: adapter)

            adapter.presenter = FeedStoryPresenter(
                storyView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view)
            )
            return view
        })
    }
}
