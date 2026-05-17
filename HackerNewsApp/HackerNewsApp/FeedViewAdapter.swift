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
    
    private typealias FeedStoryPresentationAdapter = LoadResourcePresentationAdapter<Story, WeakRefVirtualProxy<FeedStoryCellController>>
    
    init(controller: FeedViewController, loader: @escaping (Int) -> StoryLoader.Publisher) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = FeedStoryPresentationAdapter(loader: { [loader] in
                loader(model.id)
            })
            
            let view = FeedStoryCellController(delegate: adapter)

            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: FeedStoryPresenter.map
            )
            return view
        })
    }
}
