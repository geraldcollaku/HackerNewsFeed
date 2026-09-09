//
//  FeedUIComposer.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 07.03.26.
//

import Foundation
import UIKit
import Combine
import HackerNewsFeed
import HackerNewsFeediOS

@MainActor
public enum FeedUIComposer {
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedId>, FeedViewAdapter>
    
    public static func feedComposedWith(
        loader: @MainActor @escaping () -> AnyPublisher<Paginated<FeedId>, Error>,
        storyLoader: @MainActor @escaping (Int) -> StoryLoader.Publisher,
        selection: @MainActor @escaping (FeedId) -> Void = { _ in }
    ) -> ListViewController {
        let presentationAdapter = FeedPresentationAdapter(loader: { loader() })
        
        let feedController = ListViewController.makeWith(title: FeedPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                loader: { storyLoader($0) },
                selection: selection),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: { $0 })

        return feedController
    }
}

private extension ListViewController {
    static func makeWith(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = FeedPresenter.title
        return feedController
    }
}
