//
//  CombineHelpers.swift
//  HackerNewsApp
//
//  Created by Gerald Collaku on 28.04.26.
//

import Foundation
import Combine
import HackerNewsFeed

extension Paginated {
    public init(items: [Item], loadMorePublisher: (() -> AnyPublisher<Self, Error>)?) {
        self.init(items: items, loadMore: loadMorePublisher.map { publisher in
            return { completion in
                publisher().subscribe(Subscribers.Sink(receiveCompletion: { result in
                    if case let .failure(error) = result {
                        completion(.failure(error))
                    }
                }, receiveValue: { result in
                    completion(.success(result))
                }))
            }
        })
    }
    
    var loadMorePublisher: (() -> AnyPublisher<Self, Error>)? {
        guard let loadMore = loadMore else { return nil }
        
        return {
            Deferred {
                Future(loadMore)
            }.eraseToAnyPublisher()
        }
    }
}

@MainActor
public extension HTTPClient {
    typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>
    
    func getPublisher(url: URL) -> Publisher {
        var task: Task<Void, Never>?
        return Deferred {
            Future { completion in
                nonisolated(unsafe) let uncheckedCompletion = completion
                task = Task.immediate {
                    do {
                        let result = try await self.get(from: url)
                        uncheckedCompletion(.success(result))
                    } catch {
                        uncheckedCompletion(.failure(error))
                    }
                }
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

public extension LocalFeedLoader {
    typealias Publisher = AnyPublisher<[FeedId], Error>
    func loadPublisher() -> Publisher {
        return Deferred {
            Future { completion in
                completion(Result { try self.load() })
            }
        }
        .eraseToAnyPublisher()
    }
}

public extension StoryLoader {
    typealias Publisher = AnyPublisher<Story, Error>
    
    func loadStoryPublisher(with id: Int) -> Publisher {
        return Deferred {
            Future { completion in
                completion(Result {
                    try self.loadStory(with: id)
                })
            }
            
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Story {
    func caching(to cache: StoryCache, with id: Int) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
    }
}

extension StoryCache {
    func saveIgnoringResult(_ story: Story) {
        try? save(story) 
    }
}


extension Publisher where Output == [FeedId] {
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
    }
}

extension Publisher where Output == Paginated<FeedId> {
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
    }
}

extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedId]) {
       try? save(feed)
    }
    
    func saveIgnoringResult(_ feed: Paginated<FeedId>) {
        saveIgnoringResult(feed.items)
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
    
    func subscribe(onSome scheduler: some Scheduler) -> AnyPublisher<Output, Failure> {
        subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    func receive(onSome scheduler: some Scheduler) -> AnyPublisher<Output, Failure> {
        receive(on: scheduler)
            .eraseToAnyPublisher()
    }
}

extension Scheduler where Self == CoreDataFeedStoreScheduler {
    static func scheduler(for store: CoreDataFeedStore) -> Self {
        CoreDataFeedStoreScheduler(store: store)
    }
}

struct CoreDataFeedStoreScheduler: Scheduler {
    
    var now: DispatchQueue.SchedulerTimeType { .init(.now())}
    
    var minimumTolerance: DispatchQueue.SchedulerTimeType.Stride {
        .zero
    }
    
    private let store: CoreDataFeedStore
    
    init(store: CoreDataFeedStore) {
        self.store = store
    }
    
    func schedule(after date: DispatchQueue.SchedulerTimeType, interval: DispatchQueue.SchedulerTimeType.Stride, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) -> any Cancellable {
        if store.contextQueue == .main, Thread.isMainThread {
            action()
        } else {
            nonisolated(unsafe) let uncheckedAction = action
            Task.immediate {
                await store.perform {
                    uncheckedAction()
                }
            }
        }
        return AnyCancellable {}
    }
    
    
    func schedule(after date: DispatchQueue.SchedulerTimeType, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
        if store.contextQueue == .main, Thread.isMainThread {
            action()
        } else {
            nonisolated(unsafe) let uncheckedAction = action
            Task.immediate {
                await store.perform {
                    uncheckedAction()
                }
            }
        }
    }
    
    func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        if store.contextQueue == .main, Thread.isMainThread {
            action()
        } else {
            nonisolated(unsafe) let uncheckedAction = action
            Task.immediate {
                await store.perform {
                    uncheckedAction()
                }
            }
        }
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
