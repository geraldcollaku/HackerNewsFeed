//
//  SceneDelegate.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 31.03.26.
//

import os
import UIKit
import Combine
import CoreData
import HackerNewsFeed
import HackerNewsFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private lazy var scheduler: any Scheduler = {
        if let store = store as? CoreDataFeedStore {
            return .scheduler(for: store)
        }
        return DispatchQueue(label: "com.hackernews.infraqueue", qos: .userInitiated, attributes: .concurrent)
    }()
    
    private lazy var httpClient: HTTPClient =  URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    private lazy var logger = Logger(subsystem: "com.hackernewsfeed.HackerNewsApp", category: "main")
    
    private lazy var store: FeedStore & StoryStore & StoreScheduler & Sendable = {
        do {
            return try CoreDataFeedStore(storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("feed-store.sqlite"))
        } catch {
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            logger.fault("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            return InMemoryFeedStore()
        }
    }()
    
    private lazy var localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)

    private lazy var baseURL = URL(string: "http://localhost:3000")!
    
    private lazy var navigationController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
        loader: makeRemoteFeedLoaderWithLocalFallback,
        storyLoader: loadLocalStoryWithRemoteFallback,
        selection: showComments
    ))
    
    convenience init(scheduler: any Scheduler, httpClient: HTTPClient, store: FeedStore & StoryStore & StoreScheduler & Sendable) {
        self.init()
        self.scheduler = scheduler
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
        scheduler.schedule { [localFeedLoader, logger] in
            do {
                try localFeedLoader.validateCache()
            } catch {
                logger.error("Failed to validate cache with error: \(error.localizedDescription)")
            }
        }
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
        return makeRemoteFeedLoader()
            .receive(onSome: scheduler)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map(makeFirstPage)
            .subscribe(onSome: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteLoadMoreLoader(last: FeedId?) -> AnyPublisher<Paginated<FeedId>, Error> {
        return localFeedLoader.loadPublisher()
            .zip(makeRemoteFeedLoader(after: last))
            .map { (cachedItems, newItems) in
                (cachedItems + newItems, newItems.last)
            }
            .map(makePage)
            .receive(onSome: scheduler)
            .caching(to: localFeedLoader)
            .subscribe(onSome: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteFeedLoader(after: FeedId? = nil) -> AnyPublisher<[FeedId], Error> {
        let url = FeedEndpoint.get(after: after).url(baseURL: baseURL)
        
        return httpClient
            .getPublisher(url: url)
            .tryMap(FeedItemsMapper.map)
            .eraseToAnyPublisher()
    }
    
    private func makeFirstPage(items: [FeedId]) -> Paginated<FeedId> {
        makePage(items: items, last: items.last)
    }
    
    private func makePage(items: [FeedId], last: FeedId?) -> Paginated<FeedId> {
        Paginated(items: items, loadMorePublisher: last.map { last in
            { self.makeRemoteLoadMoreLoader(last: last) }
        })
    }
    
    private func loadLocalStoryWithRemoteFallback(id: Int) async throws -> Story {
        do {
            return try await loadLocalStory(id: id)
        } catch {
            return try await loadAndCacheRemoteStory(id: id)
        }
    }
    
    private func loadLocalStory(id: Int) async throws -> Story {
        try await store.schedule { [store] in
            let localStoryLoader = LocalStoryLoader(store: store)
            let story = try localStoryLoader.loadStory(with: id)
            return story
        }
    }
    
    private func loadAndCacheRemoteStory(id: Int) async throws -> Story {
        let url = StoryEndpoint.get(id: FeedId(id: id)).url(baseURL: baseURL)
        let (data, response) = try await httpClient.get(from: url)
        let story = try StoryItemMapper.map(data, from: response)
        await store.schedule { [store] in
            let localStoryLoader = LocalStoryLoader(store: store)
            try? localStoryLoader.save(story)
        }
        return story
    }
    
    private func makeRemoteStoryLoader(with id: Int) -> AnyPublisher<Story, Error> {
        let url = StoryEndpoint.get(id: FeedId(id: id)).url(baseURL: baseURL)
        
        return httpClient
            .getPublisher(url: url)
            .tryMap(StoryItemMapper.map)
            .eraseToAnyPublisher()
    }
    
}

protocol StoreScheduler {
    @MainActor
    func schedule<T>(_ action: @escaping @Sendable () throws -> T) async rethrows -> T
}

extension CoreDataFeedStore: StoreScheduler {
    @MainActor
    func schedule<T>(_ action: @escaping @Sendable () throws -> T) async rethrows -> T {
        if contextQueue == .main {
            return try action()
        } else {
            return try await perform(action)
        }
    }
}

extension InMemoryFeedStore: StoreScheduler {
    @MainActor
    func schedule<T>(_ action: @escaping @Sendable () throws -> T) async rethrows -> T {
        try action()
    }
}
