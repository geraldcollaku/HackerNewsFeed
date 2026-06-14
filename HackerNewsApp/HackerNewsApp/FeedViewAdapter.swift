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
        
        let loadMore = LoadMoreCellController {
            viewModel.loadMore? { _ in }
        }
        
        let loadMoreSection = [CellController(id: UUID(), loadMore)]
        
        controller?.display(feed, loadMoreSection)
    }
}
