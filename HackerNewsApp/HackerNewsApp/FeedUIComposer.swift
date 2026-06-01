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

public enum FeedUIComposer {
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedId], FeedViewAdapter>
    
    public static func feedComposedWith(
        loader: @escaping () -> AnyPublisher<[FeedId], Error>,
        storyLoader: @escaping (Int) -> StoryLoader.Publisher,
        selection: @escaping (FeedId) -> Void = { _ in }
    ) -> ListViewController {
        let presentationAdapter = FeedPresentationAdapter(loader: { loader().dispatchOnMainQueue() })
        
        let feedController = ListViewController.makeWith(title: FeedPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                loader: { storyLoader($0).dispatchOnMainQueue() },
                selection: selection),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map)

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
