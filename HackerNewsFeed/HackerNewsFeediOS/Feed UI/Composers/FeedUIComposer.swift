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
            loadingView: WeakRefVirtualProxy(feedController))

        return feedController
    }
}

private final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
           return DispatchQueue.main.async {
                completion()
            }
        }
        
        completion()
    }
}

extension MainQueueDispatchDecorator: StoryLoader where T == StoryLoader {
    func loadStory(with id: Int, completion: @escaping (StoryLoader.Result) -> Void) -> StoryLoaderTask {
        return decoratee.loadStory(with: id) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
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

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedStoryView where T: FeedStoryView {
    func display(_ viewModel: FeedStoryViewModel) {
        object?.display(viewModel)
    }
}

private class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let loader: StoryLoader
    
    init(controller: FeedViewController, loader: StoryLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            let adapter = FeedStoryLoaderPresentationAdapter(model: model, storyLoader: loader)
            let view = FeedStoryCellController(delegate: adapter)

            adapter.presenter = FeedStoryPresenter(view: WeakRefVirtualProxy(view))
            return view
        }
    }
}

private final class FeedStoryLoaderPresentationAdapter: FeedStoryCellControllerDelegate {
    private let model: FeedId
    private let storyLoader: StoryLoader
    private var task: StoryLoaderTask?
    
    var presenter: FeedStoryPresenter?
    
    init(model: FeedId, storyLoader: StoryLoader) {
        self.model = model
        self.storyLoader = storyLoader
    }
    
    func didRequestStory() {
        presenter?.didStartLoadingStory()
        
        task = storyLoader.loadStory(with: model.id) { [weak self] result in
            switch result {
            case let .success(story):
                self?.presenter?.didFinishLoadingStory(with: story)
            case let .failure(error):
                self?.presenter?.didFinishLoadingStory(with: error)
            }
        }
    }
    
    func didCancelStoryRequest() {
        task?.cancel()
        task = nil
    }
}

private final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedIdLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedIdLoader: FeedLoader) {
        self.feedIdLoader = feedIdLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedIdLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
