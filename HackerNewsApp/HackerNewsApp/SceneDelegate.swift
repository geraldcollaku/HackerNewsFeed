//
//  SceneDelegate.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 31.03.26.
//

import UIKit
import HackerNewsFeed
import HackerNewsFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let url = URL(string: "https://hacker-news.firebaseio.com/v0")!
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let feedLoader = RemoteFeedLoader(url: url.appendingPathComponent("newstories.json"), client: client)
        let storyLoader = RemoteStoryDataLoader(
            url: { id in
                return url.appendingPathComponent("item/\(id).json")
            },
            client: client
        )
        let feedViewController = FeedUIComposer.feedComposedWith(loader: feedLoader, storyLoader: storyLoader)
        
        window?.rootViewController = feedViewController
    }
}

