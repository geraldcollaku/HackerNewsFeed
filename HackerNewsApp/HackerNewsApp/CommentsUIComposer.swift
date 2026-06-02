//
//  CommentsUIComposer.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 01.06.26.
//

import Foundation
import UIKit
import Combine
import HackerNewsFeed
import HackerNewsFeediOS

public enum CommentsUIComposer {
    private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[FeedComment], CommentsViewAdapter>
    
    public static func commentsComposedWith(loader: @escaping () -> AnyPublisher<[FeedComment], Error>) -> ListViewController {
        let presentationAdapter = CommentsPresentationAdapter(loader: { loader().dispatchOnMainQueue() })
        
        let commentsController = ListViewController.makeCommentsViewControllerWith(title: FeedCommentsPresenter.title)
        commentsController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: CommentsViewAdapter(controller: commentsController),
            loadingView: WeakRefVirtualProxy(commentsController),
            errorView: WeakRefVirtualProxy(commentsController),
            mapper: { FeedCommentsPresenter.map($0) })

        return commentsController
    }
}

private extension ListViewController {
    static func makeCommentsViewControllerWith(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "FeedComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.title = title
        return controller
    }
}

final class CommentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?

    init(controller: ListViewController) {
        self.controller = controller
    }

    func display(_ viewModel: FeedCommentsViewModel) {
        controller?.display(viewModel.comments.map { viewModel in
            CellController(id: UUID(), FeedCommentCellController(model: viewModel))
        })
    }
}
