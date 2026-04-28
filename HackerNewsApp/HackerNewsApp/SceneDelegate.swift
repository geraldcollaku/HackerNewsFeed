//
//  SceneDelegate.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 31.03.26.
//

import UIKit
import Combine
import CoreData
import HackerNewsFeed
import HackerNewsFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient =  URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    private lazy var store: FeedStore & StoryStore = {
        let url = NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("feed-store.sqlite")
        return try! CoreDataFeedStore(storeURL: url)
    }()
    
    private lazy var localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
    private lazy var url = URL(string: "https://hacker-news.firebaseio.com/v0")!
    private lazy var remoteFeedLoader = RemoteFeedLoader(url: url, client: httpClient)
    
    convenience init(httpClient: HTTPClient, store: FeedStore & StoryStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        window?.rootViewController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
            loader: makeRemoteFeedLoaderWithLocalFallback,
            storyLoader: makeRemoteStoryLoaderWithLocalFallback))
        
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> RemoteFeedLoader.Publisher {
        let remoteFeedLoader = RemoteFeedLoader(url: url.appendingPathComponent("newstories.json"), client: httpClient)
        let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)

        return remoteFeedLoader
            .loadPublisher()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    private func makeRemoteStoryLoaderWithLocalFallback(id: Int) -> StoryLoader.Publisher {
        let remoteStoryLoader = RemoteStoryDataLoader(
            url: { [url] storyId in
                url.appendingPathComponent("item/\(storyId).json")
            },
            client: httpClient
        )
        let localStoryLoader = LocalStoryLoader(store: store)
        
        return localStoryLoader
            .loadStoryPublisher(with: id)
            .fallback(to: {
                remoteStoryLoader
                    .loadStoryPublisher(with: id)
                    .caching(to: localStoryLoader, with: id)
            })
    }
}
