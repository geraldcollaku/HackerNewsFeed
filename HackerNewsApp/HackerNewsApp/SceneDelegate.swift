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
        let baseURL = url
        let remoteStoryLoader = RemoteStoryDataLoader(
            url: { id in
                return baseURL.appendingPathComponent("item/\(id).json")
            },
            client: httpClient
        )
        let localStoryLoader = LocalStoryLoader(store: store)
        
        window?.rootViewController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
            loader: makeLocalFeedLoaderWithLocalFallback,
            storyLoader: FeedStoryLoaderWithFallbackComposite(
                primary: FeedStoryLoaderCacheDecorator(
                    decoratee: remoteStoryLoader,
                    cache: localStoryLoader),
                fallback: localStoryLoader)))
        
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func makeLocalFeedLoaderWithLocalFallback() -> RemoteFeedLoader.Publisher {
        let remoteFeedLoader = RemoteFeedLoader(url: url.appendingPathComponent("newstories.json"), client: httpClient)
        let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)

        return remoteFeedLoader
            .loadPublisher()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
}

public extension FeedLoader {
    typealias Publisher = AnyPublisher<[FeedId], Error>
    func loadPublisher() -> Publisher {
        return Deferred {
            Future(self.load)
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == [FeedId] {
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
    }
}

extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedId]) {
        save(feed) { _ in }
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
    }
}

extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    
    static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
        ImmediateWhenOnMainQueueScheduler()
    }
    
    struct ImmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        var now: DispatchQueue.SchedulerTimeType {
            DispatchQueue.main.now
        }
        
        var minimumTolerance: SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }
        
        func schedule(options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
            guard Thread.isMainThread else {
               return DispatchQueue.main.schedule(options: options, action)
            }
            
            action()
        }
        
        func schedule(after date: DispatchQueue.SchedulerTimeType, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }
        
        func schedule(after date: DispatchQueue.SchedulerTimeType, interval: DispatchQueue.SchedulerTimeType.Stride, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) -> any Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, action)
        }
    }
}
