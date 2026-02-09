//
//  CoreDataFeedStore.swift
//  HackerNewsFeed
//
//  Created by Gerald Collaku on 08.02.26.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let context = self.context
        context.perform {
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedId], timestamp: Date, completion: @escaping InsertionCompletion) {
        let context = self.context
        context.perform {
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.news = ManagedNews.ids(from: feed, in: context)
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let context = self.context
        context.perform {
            do {
                try ManagedCache
                    .find(in: context)
                    .map(context.delete)
                    .map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    @objc(ManagedCache)
    private class ManagedCache: NSManagedObject {
        @NSManaged var timestamp: Date
        @NSManaged var news: NSOrderedSet
        
        static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
            let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
            
            request.returnsObjectsAsFaults = false
            return try context.fetch(request).first
        }
        
        static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
            try find(in: context).map(context.delete)
            return ManagedCache(context: context)
        }

        var localFeed: [LocalFeedId] {
           news.compactMap {
               ($0 as? ManagedNews)?.local
            }
        }
    }
    
    @objc(ManagedNews)
    private class ManagedNews: NSManagedObject {
        @NSManaged var id: Int
        
        static func ids(from localFeed: [LocalFeedId], in context: NSManagedObjectContext) -> NSOrderedSet {
            return NSOrderedSet(array: localFeed.map { local in
                let managed = ManagedNews(context: context)
                managed.id = local.id
                return managed
            })
        }
        
        var local: LocalFeedId {
            LocalFeedId(id: id)
        }
    }
}

private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        var loadError: Error?
        container.loadPersistentStores {
            loadError = $1
        }
        
        try loadError.map {
            throw LoadingError.failedToLoadPersistentStores($0)
        }
        
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap {
                NSManagedObjectModel(contentsOf: $0)
            }
    }
}
