//
//  FeedUIComposer.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 07.03.26.
//

import HackerNewsFeed
import Foundation
import UIKit

public enum FeedUIComposer {
    
    public static func feedComposedWith(loader: FeedLoader, storyLoader: StoryLoader) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedIdLoader: MainQueueDispatchDecorator(decoratee: loader))
        
        let feedController = FeedViewController.makeWith(
            delegate: presentationAdapter,
            title: FeedPresenter.title
        )
        
        presentationAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(
                controller: feedController,
                loader: MainQueueDispatchDecorator(decoratee: storyLoader)),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController))

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
