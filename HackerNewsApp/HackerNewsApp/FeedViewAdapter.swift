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

    private typealias FeedStoryPresentationAdapter = LoadResourcePresentationAdapter<Story, WeakRefVirtualProxy<FeedStoryCellController>>

    private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedId>, FeedViewAdapter>
    
    init(controller: ListViewController, loader: @escaping (Int) -> StoryLoader.Publisher, selection: @escaping (FeedId) -> Void) {
        self.controller = controller
        self.loader = loader
        self.selection = selection
    }

    func display(_ viewModel: Paginated<FeedId>) {
        let feed: [CellController] = viewModel.items.map { model in
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
            return CellController(id: model, view)
        }
        
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller?.display(feed)
            return
        }
        
        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
        
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        
        loadMoreAdapter.presenter = LoadResourcePresenter(
            resourceView: self,
            loadingView: WeakRefVirtualProxy(loadMore),
            errorView: WeakRefVirtualProxy(loadMore),
            mapper: { $0 })
        
        let loadMoreSection = [CellController(id: UUID(), loadMore)]
        
        controller?.display(feed, loadMoreSection)
    }
}
