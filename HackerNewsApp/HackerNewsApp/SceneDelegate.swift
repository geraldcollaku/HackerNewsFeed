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
    
    let localStoreURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("feed-store.sqlite")
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let url = URL(string: "https://hacker-news.firebaseio.com/v0")!
        
        let remoteClient = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(url: url.appendingPathComponent("newstories.json"), client: remoteClient)
        let remoteStoryLoader = RemoteStoryDataLoader(
            url: { id in
                return url.appendingPathComponent("item/\(id).json")
            },
            client: remoteClient
        )

        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
        let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
        let localStoryLoader = LocalStoryLoader(store: localStore)
        
        window?.rootViewController = FeedUIComposer.feedComposedWith(
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
                fallback: localStoryLoader))
    }
    
    func makeRemoteClient() -> HTTPClient {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }
}
