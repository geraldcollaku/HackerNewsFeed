//
//  FeedViewAdapter.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 21.03.26.
//

import HackerNewsFeed
import HackerNewsFeediOS
import Foundation

class FeedViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    private let loader: (Int) -> StoryLoader.Publisher
    private let selection: (FeedId) -> Void
    private let currentFeed: [FeedId: CellController]

    private typealias FeedStoryPresentationAdapter = LoadResourcePresentationAdapter<Story, WeakRefVirtualProxy<FeedStoryCellController>>

    private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedId>, FeedViewAdapter>
    
    init(currentFeed: [FeedId: CellController] = [:], controller: ListViewController, loader: @escaping (Int) -> StoryLoader.Publisher, selection: @escaping (FeedId) -> Void) {
        self.currentFeed = currentFeed
        self.controller = controller
        self.loader = loader
        self.selection = selection
    }

    func display(_ viewModel: Paginated<FeedId>) {
        guard let controller = controller else { return }
        var currentFeed = self.currentFeed
        let feed: [CellController] = viewModel.items.map { model in
            if let controller = currentFeed[model] {
                return controller
            }
            
            let adapter = FeedStoryPresentationAdapter(loader: { [loader] in
                loader(model.id)
            })
            
            let view = FeedStoryCellController(delegate: adapter, selection: { [selection] in
                selection(model)
            })
            
            view.onNeedsReconfigure = { [weak controller = self.controller, id = AnyHashable(model)] in
                controller?.update(id: id)
            }
            
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: FeedStoryPresenter.map
            )
            let controller = CellController(id: model, view)
            currentFeed[model] = controller
            return controller
        }
        
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller.display(feed)
            return
        }
        
        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
        
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        
        loadMoreAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(currentFeed: currentFeed,
                                          controller: controller,
                                          loader: loader,
                                          selection: selection),
            loadingView: WeakRefVirtualProxy(loadMore),
            errorView: WeakRefVirtualProxy(loadMore),
            mapper: { $0 })
        
        let loadMoreSection = [CellController(id: UUID(), loadMore)]
        
        controller.display(feed, loadMoreSection)
    }
}
