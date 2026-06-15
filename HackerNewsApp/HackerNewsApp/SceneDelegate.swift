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
    // Local development: backend running on the Mac via `npm start` (reachable
    // from the Simulator at localhost). Swap back to the deployed URL for release.
    private lazy var baseURL = URL(string: "http://localhost:3000")!
    
    private lazy var navigationController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
        loader: makeRemoteFeedLoaderWithLocalFallback,
        storyLoader: makeRemoteStoryLoaderWithLocalFallback,
        selection: showComments
    ))
    
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
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func showComments(for feedId: FeedId) {
        let url = FeedCommentsEndpoint.get(feedId.id).url(baseURL: baseURL)
        let comments = CommentsUIComposer.commentsComposedWith(loader: makeRemoteCommentsLoader(url: url))
        navigationController.pushViewController(comments, animated: true)
    }
    
    private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[FeedComment], Error> {
        return { [httpClient] in
            return httpClient
                .getPublisher(url: url)
                .tryMap(FeedCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedId>, Error> {
        let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
        let feedUrl = FeedEndpoint.get().url(baseURL: baseURL)
        return httpClient
            .getPublisher(url: feedUrl)
            .tryMap(FeedItemsMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map {
                Paginated(items: $0)
            }
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteStoryLoaderWithLocalFallback(id: Int) -> StoryLoader.Publisher {
        let remoteStoryLoader = RemoteStoryDataLoader(
            url: { [baseURL] storyId in
                baseURL.appendingPathComponent("/v0/item/\(storyId)")
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
