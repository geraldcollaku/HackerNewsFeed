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
    
    public static func feedComposedWith(loader: @escaping () -> AnyPublisher<[FeedId], Error>, storyLoader: @escaping (Int) -> StoryLoader.Publisher) -> FeedViewController {
        let presentationAdapter = FeedPresentationAdapter(loader: { loader().dispatchOnMainQueue() })
        
        let feedController = FeedViewController.makeWith(
            delegate: presentationAdapter,
            title: FeedPresenter.title
        )
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                loader: { storyLoader($0).dispatchOnMainQueue() }),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map)

        return feedController
    }
}

private extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = FeedPresenter.title
        return feedController
    }
}
