//
//  CoreDataFeedStore.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 08.02.26.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: Sendable {
    private static let modelName = "FeedStore"
    @MainActor
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    let bundle = Bundle(for: CoreDataFeedStore.self)
    
    private let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    enum StoreError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    public enum ContextQueue {
        case main
        case background
    }
    
    public var contextQueue: ContextQueue {
        context == container.viewContext ? .main : .background
    }
    
    @MainActor
    public convenience init(storeURL: URL, contextQueue: ContextQueue = .background) throws {
        guard let model = CoreDataFeedStore.model else {
            throw StoreError.modelNotFound
        }
    
        try self.init(storeURL: storeURL, model: model)
    }
    
    public init(storeURL: URL, contextQueue: ContextQueue = .background, model: NSManagedObjectModel) throws {
        do {
            container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, url: storeURL, in: bundle)
            context = contextQueue == .main ? container.viewContext : container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentStores(error)
        }
    }
    
    public func perform<T>(_ action: @escaping @Sendable () throws -> T) async rethrows -> T {
        try await context.perform(action)
    }

    private func cleanUpReferencesToPersistentStore() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStore()
    }
}
