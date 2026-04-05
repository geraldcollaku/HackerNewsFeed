//
//  SceneDelegate.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 31.03.26.
//

import UIKit
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
    
    convenience init(httpClient: HTTPClient, store: FeedStore & StoryStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        configureWindow()
    }
    
    func configureWindow() {
        let url = URL(string: "https://hacker-news.firebaseio.com/v0")!
        
        let remoteFeedLoader = RemoteFeedLoader(url: url.appendingPathComponent("newstories.json"), client: httpClient)
        let remoteStoryLoader = RemoteStoryDataLoader(
            url: { id in
                return url.appendingPathComponent("item/\(id).json")
            },
            client: httpClient
        )

        let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
        let localStoryLoader = LocalStoryLoader(store: store)
        
        window?.rootViewController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
            loader: FeedLoaderWithFallbackComposite(
                primary: FeedLoaderCacheDecorator(
                    decoratee: remoteFeedLoader,
                    cache: localFeedLoader
                ),
                fallback: localFeedLoader),
            storyLoader: FeedStoryLoaderWithFallbackComposite(
                primary: FeedStoryLoaderCacheDecorator(
                    decoratee: remoteStoryLoader,
                    cache: localStoryLoader),
                fallback: localStoryLoader)))
    }
}
